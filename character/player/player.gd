extends Character2d

## 玩家类
class_name Player
#@onready var sprite_2d_player: AnimationPlayer = $Animation/Sprite2DPlayer

@onready var ray_cast_2d: RayCast2D = $RayCast2D
#var can_move: bool = false
#var _footstep = preload("res://assest/sfx/character/footstep06.ogg")
@export var move: GUIDEAction

var craft_system: CraftSystem
## 道具增加通知
var walk_paths

func learn_skill(skill: SkillInstance) -> void:
	skill_system.add_skill(skill)


func test() -> void:
	inventory.add_item(ItemFactory.create_item("lover_ring"))
	inventory.add_item(ItemFactory.create_item("memory_potion"))
	inventory.add_item(ItemFactory.create_item("bones"))
	inventory.add_item(ItemFactory.create_item("blue_herb", 100))
	inventory.add_item(ItemFactory.create_item("eternal_heart"))
	inventory.gold = 3000
	#Global.memory = 2
	#Global.set_npc_die("dog", true)
	#inventory.add_item(ItemFactory.create_item("defor_relieve_potion"))
	inventory.add_item(ItemFactory.create_item("bones"))
	inventory.add_item(ItemFactory.create_item("sword"))
	instance.current_hp = 1000
	
	instance.current_mp = 1000
	instance.template.base_attack = 10
	instance.template.base_defense = 58
	#skill_system.add_skill(SkillFactory.create_skill("dunt"))
	#skill_system.add_skill(SkillFactory.create_skill("fireball"))
	skill_system.add_skill(SkillFactory.create_skill("dunt"))
	#craft_system.add_craft(CraftFactory.create_craft("healing_potion"))

func open_bag() -> void:
	inventory.open(inventory)


func get_data() -> Dictionary:
	var data: Dictionary
	## 保存instance的数据
	data.set("instance", instance.get_data())
	## 保存inventory的数据
	data.set("inventory", inventory.get_data())
	
	data.set("skill", skill_system.get_data())
	## 
	data.set("craft", craft_system.get_data())
	
	data.set("position", global_position)
	
	for e: String in instance.equipment:
		## 在背包中查找该物品并装备
		var item: ItemInstance = inventory.get_item_by_template(e)
		if item:
			item.unequip(instance)
			#item.is_equipped = false
	return data

func set_data(data: Dictionary) -> void:
	global_position = data.get("position")
	instance.set_data(data["instance"])
	inventory.set_data(data["inventory"])
	skill_system.set_data(data["skill"])
	craft_system.set_data(data["craft"])
	## 设置装备和buff效果
	## 先遍历装备槽
	for e: ItemInstance in inventory.get_items():
		## 在背包中查找该物品并装备
		if e.get_type() == ItemTemplate.ItemType.EQUIPMENT:
			if e.is_equipped:
				e.equip(instance)
			
		
	SignalManager.on_player_ui_update.emit(self)


func initialize() -> void:
	add_to_group(&'player')
	inventory = InventorySyetem.new("勇士")
	skill_system = SkillSystem.new()
	craft_system = CraftSystem.new()
	craft_system.user_name = "勇士"
	skill_system.user_name = "勇士"
	instance = CharacterFactory.create_character("player1")
	instance.on_character_equipment_equip_unquip.connect(_on_character_equipment_equip_unquip)
	inventory.gold = 220
	#test()

func _ready() -> void:
	#set_process(false)
	ray_cast_2d.enabled = false
	SignalManager.on_player_change_inventory.connect(change_inventory)
	move.triggered.connect(_move_in_direction)
	SignalManager.on_player_learn_skill.connect(learn_skill)
	

func player_audio(_type: String) -> void:
	SignalManager.on_change_audio_effect.emit(_type)

func _on_character_equipment_equip_unquip(_equipped_id: String, _tag) -> void:
	if _equipped_id.is_empty():
		push_error("id error")
		return	
	if !_tag:
		## 找到这个物品
		var equipped_item: ItemInstance = inventory.get_item_by_id(_equipped_id)
		if equipped_item == null:
			push_error("there is no this equipped item")
			return
		## 卸下这个物品
		equipped_item.unequip(instance)
		

func play_animation_with(_type: String, _dir_right: bool = false) -> void:
	match _type:
		"hurt": sprite_2d_player.play("hurt")
		"hit": sprite_2d_player.play("hit")
		"fireball": sprite_2d_player.play("skill_fireball")
		"blood": sprite_2d_player.play("skill_blood")
		"potion": sprite_2d_player.play("skill_potion")
	player_audio("attack")



func paly_animation() -> void:
	vfx_sprite_2d.visible = false
	sprite_2d_player.play(&'walk')
	player_audio("walk")

## ray_cast_2d: RayCast2D 方向控制
## 使用说明：设置射线检测方向并自动更新参数
func set_ray_cast_direction(dir: Vector2) -> bool:
	match dir:
		Vector2.UP:ray_cast_2d.rotation_degrees = 180
		Vector2.DOWN:ray_cast_2d.rotation_degrees = 0
		Vector2.LEFT:ray_cast_2d.rotation_degrees = 90
		Vector2.RIGHT:ray_cast_2d.rotation_degrees = -90
		_:
			#push_error("Invalid direction: ", direction)
			return false
	# 启用并强制更新射线状态
	ray_cast_2d.enabled = true
	ray_cast_2d.force_raycast_update()
	return true
	



var direction: String
# 键盘输入处理
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_left"):
		handle_mouse_click(get_global_mouse_position())

#var is_moving_by_mouse: bool = false

# 处理键盘输入
func _move_in_direction() -> void:
	#if is_moving_by_mouse:
	var dir_vector: Vector2 = move.value_axis_2d
	# 设置射线方向
	if !set_ray_cast_direction(dir_vector):
		return
	# 检测前方是否有障碍
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		if collider.has_method("on_player_interact"):
			if collider.has_method("play_dialogue"):
				InputManager.set_game_mode(InputManager.GameMode.DIALOGIC_MODE)
			collider.on_player_interact(self)
			ray_cast_2d.enabled = false
			

		return
	# 无障碍则移动
	move_to(tile_size * dir_vector)
	paly_animation()

# 处理鼠标点击
func handle_mouse_click(target_pos: Vector2) -> void:
	#if is_moving_by_mouse:
		#return
	#is_moving_by_mouse = true
	# 设置朝向
	var dir_vector: Vector2 = move.value_axis_2d
	# 设置射线方向
	set_ray_cast_direction(dir_vector)
	
	# 检测是否点击了敌人
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		if collider.has_method("on_player_interact"):
			collider.on_player_interact(self)
			return
	# 执行寻路
	find_way(target_pos)


func find_way(target_pos: Vector2) -> void:
	var navigator: AdvancedAStarNavigator = LevelManager.current_level.navigator
	walk_paths = navigator.find_path(global_position, target_pos, false)
	if !walk_paths.is_empty():	
		##print("路径查找成功！")
		set_process(true)##移动	
	pass



# 获取目标方向
func get_direction_to(target: Vector2) -> String:
	var rel_pos = target - global_position
	if abs(rel_pos.x) > abs(rel_pos.y):
		return "right" if rel_pos.x > 0 else "left"
	else:
		return "down" if rel_pos.y > 0 else "up"


var current_path_index: int = 0
var move_speed: float = 100
var tile_size: int = 16
#func _process(delta: float) -> void:
	## 逐步移动角色
	#if walk_paths.size() > 0 and current_path_index < walk_paths.size():
		#var target_pos = walk_paths[current_path_index]
		#var move_distance = move_speed * delta
		#
		## 移动角色
		#global_position = global_position.move_toward(
			#target_pos, move_distance)
		#
		## 检查是否到达当前路径点
		#if global_position.distance_to(target_pos) < 1.0:
			#current_path_index += 1
	#else:
		#walk_paths.clear()
		#
		#current_path_index = 0
		##is_moving_by_mouse = false
		#set_process(false)

## gold, exp, item
func gain_reward(data: Dictionary) -> void:
	instance.gain_exp(data["exp"])
	if data.has("gold"):
		inventory.gold += data["gold"]
	
	if data.has("item") and data.get("item"):
		for item in data.get("item"):
			if item:
				inventory.add_item(item)
				LogManager.add_entry(tr("log_item_reward") % item.get_display_name())
		
	LogManager.add_entry(tr("log_exp_gold_reward") % [data.get("exp"), data.get("gold")])
	
	SignalManager.on_player_ui_update.emit(self)
	
func check_inventory(item_id: String) -> ItemInstance:
	if inventory == null:
		return null
	return inventory.get_item_by_template(item_id)



func use_item(item: ItemInstance) -> bool:
	if item.use("consume", instance):
		inventory.update_item(item)
		return true
	else:
		return false
	#SignalManager.on_inventory_ui_change.emit()

## reduce, remove, buy
func change_inventory(type: String, item_id: String = "", amount: int = 1) -> bool:
	
	match type:
		"reduce": 
			if inventory.reduce_item(item_id, amount):
				SignalManager.on_player_ui_update.emit(self)
				return true
		"remove":
			## 
			inventory.remove_item_by_id(item_id)
			SignalManager.on_player_ui_update.emit(self)
			return true
		"buy":
			if item_id.is_empty():
				inventory.gold += amount
			else:
				var new_item: ItemInstance = ItemFactory.create_item(item_id, amount)
				inventory.add_item(new_item)
			SignalManager.on_player_ui_update.emit(self)
			
			return true		
		_:push_error("there is no this type")
	return false

func equip(item: ItemInstance) -> void:
	## 检查这个位置有没有装备，如果有需要先卸下之前的装备然后再装备
	var id = instance.get_equipped_slot(item.get_slot())
	if id != null:
		var equipped: ItemInstance = inventory.get_item_by_id(id)
		equipped.unequip(self.instance)
	item.equip(self.instance)
	
	
func unequip(item: ItemInstance) -> void:
	item.unequip(self.instance)

func pick_up(item: ItemInstance) -> bool:
	if !inventory:
		push_error("there is no this inventory")
		return false
	if inventory.add_item(item):
		SignalManager.on_player_ui_update.emit(self)
		print(inventory.base)
		return true
		
	return false
