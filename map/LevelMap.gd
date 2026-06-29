extends Node2D

## 游戏地图
class_name LevelMap
@onready var navigation_layer: TileMapLayer = $FloorLayer
@export var level_id: int
@onready var navigator: AdvancedAStarNavigator = $AstarGridBox
@onready var wall_layer: TileMapLayer = $WallLayer
@onready var interacition_layer: TileMapLayer = $InteracitionLayer
@onready var enemy_creator: EnemyCreator = $EnemyCreator
@onready var item_creator: ItemCreator = $ItemCreator
signal scene_change_finished

#
#func _ready() -> void:
	#child_entered_tree.connect(_on_child_entered_tree)
#
func init_navigator() -> void:
	navigator.floor_layer = navigation_layer
	navigator.add_obstacle_layer(wall_layer)
	navigator.initialize_astar()
	## 动态添加
	navigator.dynamic_obstacles.clear()
	
	## 获取
	for child in interacition_layer.get_children():
		var cell: Vector2 = interacition_layer.to_local(child.global_position)
		cell = interacition_layer.local_to_map(cell)
		navigator.add_dynamic_obstacle(cell)

			#for cell in interacition_layer.get_used_cells():
		#navigator.add_dynamic_obstacle(cell)
	
	
func initialiaze() -> void:
	await get_tree().create_timer(0.03).timeout
	init_navigator()
	print("level map loading")
#	LogManager.check_orphan()

	for item: Item in get_tree().get_nodes_in_group(&'item'):
		item.initialize()	
	for enemy: Character2d in get_tree().get_nodes_in_group(&'enemy'):
		enemy.initialize()
	for npc: Character2d in get_tree().get_nodes_in_group(&'npc'):
		npc.initialize()
	
	## 获取敌人列表
	## 获取npc列表

func remove_obstacle(pos: Vector2) -> void:
	pos = navigation_layer.local_to_map(pos)
	navigator.remove_dynamic_obstacle(pos)


## 获取当前的地图所有的数据
func get_data() -> Dictionary:
	var data: Dictionary = {}
	data.set("enemy", [])
	data.set("item", [])
	data.set("door", [])
	data.set("npc", [])
	data.set("secret_step", [])
	data.set("trap", [])
	data.set("shelf", [])
	
	##data.set("obstacle", [])
	for enemy_node: Enemy in get_tree().get_nodes_in_group(&'enemy'):
		var enemy_data: Dictionary = {}
		enemy_data = enemy_node.get_data()
		if enemy_data.is_empty():
			push_warning("get enemy data empty")
		data["enemy"].append(enemy_data)

	for item_node: Item in get_tree().get_nodes_in_group(&'item'):
		var item_data: Dictionary = {}
		item_data = item_node.get_data()
		if item_data.is_empty():
			push_warning("get item data empty")		
		data["item"].append(item_data)
	for door_node: Door in get_tree().get_nodes_in_group(&'door'):
		data["door"].append(door_node.get_data())
	for npc in get_tree().get_nodes_in_group(&'npc'):
		data["npc"].append(npc.get_data())
	for step: SecretStep in get_tree().get_nodes_in_group(&'secret_step'):
		data["secret_step"].append(step.get_data())
	for trap: Trap in get_tree().get_nodes_in_group(&'trap'):
		data["trap"].append(trap.get_data())
	for shelf: BookShelf in get_tree().get_nodes_in_group(&'shelf'):
		data["shelf"].append(shelf.get_data())
		
	## 检测背包
	return data





func set_data() -> void:
	if interacition_layer == null:
		print("子场景树未加载完成")
		return
	if  !LevelManager.levels_data.has(level_id):
		print("scene no need to set")
		return
	## 设置导航部分的
	
	var current_data: Dictionary = LevelManager.levels_data[level_id]
	for child in interacition_layer.get_children():
		child.queue_free()
	
	var enemy_data: Array = current_data["enemy"]
	for dict: Dictionary in enemy_data:
		var enemy: Enemy = load(Global.enemy_scenes[dict["template_id"]]).instantiate() as Enemy
		interacition_layer.add_child(enemy)
		enemy.initialize()
		enemy.set_data(dict)
	var item_data: Array = current_data["item"]
	for dict: Dictionary in item_data:
		var item: Item = load(Global.item_scenes[dict["template_id"]]).instantiate() as Item
		item.set_data(dict)
		interacition_layer.call_deferred(&'add_child', item)
		
		
	var door_data: Array = current_data["door"]
	for dict: Dictionary in door_data:
		var door: Door = load(Global.door_scenes[dict["type"]]).instantiate() as Door
		interacition_layer.call_deferred(&'add_child', door)
		door.global_position = dict["position"]
		door.locked = dict["locked"]
		
	var npc_data: Array = current_data.get("npc")
	for dict: Dictionary in npc_data:
		var npc: Character2d = load(Global.npc_scenes[dict["character_name"]]).instantiate() as Character2d
		interacition_layer.call_deferred(&'add_child', npc)
		if npc.has_method("initialize"):
			npc.initialize()
		npc.set_data(dict)
	#print("enemy_data: %s, item_data: %s", enemy_data,item_data)
	var step_data: Array = current_data.get("secret_step")
	for dict: Dictionary in step_data:
		var step: SecretStep = load(Global.item_scenes.get("secret_step")).instantiate() as SecretStep
		step.set_data(dict)
		interacition_layer.call_deferred(&'add_child', step)

	var trap_data: Array = current_data.get("trap")
	for dict: Dictionary in trap_data:
		var trap: Trap = load(Global.item_scenes.get("trap")).instantiate() as Trap
		trap.set_data(dict)
		interacition_layer.call_deferred(&'add_child', trap)
		
	var shelf_data: Array = current_data.get("shelf")
	for dict: Dictionary in shelf_data:
		var shelf: BookShelf = load(Global.item_scenes.get("book_shelf")).instantiate() as BookShelf
		shelf.set_data(dict)
		interacition_layer.call_deferred(&'add_child', shelf)

	
## 当敌人移动时更新障碍
#func update_enemy_position(old_cell: Vector2i, new_cell: Vector2i):
	#navigator.remove_dynamic_obstacle(old_cell)
	#navigator.add_dynamic_obstacle(new_cell)





func _on_child_entered_tree(_node: Node) -> void:
	## 更新ui
	SignalManager.on_map_level_change.emit(level_id)
	
