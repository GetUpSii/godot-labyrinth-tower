extends PanelContainer

class_name InventoryUi
var instance: InventorySyetem

@onready var item_container: VBoxContainer = %ItemContainer


@onready var item_panel_container: PanelContainer = %ItemPanelContainer
@onready var item_text_label: RichTextLabel = %ItemTextLabel
@onready var delete_button: Button = %DeleteButton
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

@onready var use_button: Button = %UseButton

var current_item: ItemInstance
var player: Player
## 打开库存
func open(_instance) -> void:	
	get_parent().layer = 0
	update(_instance)
	item_container.get_child(0).grab_focus()
	set_audio()
	InputManager.set_game_mode(InputManager.GameMode.BAG_MODE)
	
func close() -> void:
	set_audio()
	get_parent().layer = -1
	InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)
	queue_free()


#
func _ready() -> void:
		# 设置PanelContainer尺寸为屏幕2/3
	self.size = Vector2(
		Global.screen_size.x * 2/3, 
		Global.screen_size.y * 2/3
	)
	self.position = (Global.screen_size - self.size) / 2
	item_panel_container.custom_minimum_size = self.size * 1/2
	SignalManager.on_inventory_ui_change.connect(_on_inventory_ui_change)
	
	# 居中显示（可选）
	##self.position = (Global.screen_size - self.custom_minimum_size) / 2
#func _ready() -> void:
	#SignalManager.on_player_ui_update.connect(_on_player_ui_update)

func _on_inventory_ui_change() -> void:
	update(instance)

func set_audio() -> void:
	audio_stream_player.play()



### 初始化
#func initialize(_player: Player) -> void:
	#player = _player
	#var inventory = player.inventory
	#self.size = Vector2(
		#Global.screen_size.x * 2/3, 
		#Global.screen_size.y * 2/3
	#)
	#self.position = (Global.screen_size - self.size) / 2
	#item_panel_container.custom_minimum_size = self.size * 1/2
	#instance = inventory
	#update(inventory)


func special_text() -> void:
	
	if Global.memory == 2:
		item_text_label.add_text(tr("item_lover_ring_familiar") + "\n")
	if Global.memory == 3:
		item_text_label.add_text(tr("item_lover_ring_message") + "\n")

func updata_label() -> void:
	item_text_label.clear()
	if current_item == null:
		return
	item_text_label.add_text(current_item.get_description() + "\n")
	
	if current_item.get_template_id() == "lover_ring":
		special_text()
	
	item_text_label.add_text(tr("ui_quantity") + str(current_item.quantity))
	## 如果是装备就要显示当前物品有没有被装备
	if current_item.is_equipment():
		if current_item.is_equipped:
			item_text_label.add_text("\n" + tr("ui_equipped"))
		else:
			item_text_label.add_text("\n" + tr("ui_unequipped"))


func update_button() -> void:
	if current_item == null:
		return
	use_button.disabled = true
	if current_item.is_equipment():
		if current_item.is_equipped:
			use_button.text = tr("ui_unequip")
		else:
			use_button.text = tr("ui_equip")
		use_button.disabled = false
		return
	elif current_item.is_consumable():
		use_button.disabled = false
	use_button.text = tr("ui_use")
	


func update(inventory: InventorySyetem) -> void:
	if inventory == null:
		return
	if instance == null:
		instance = inventory
	if player == null:
		player = Global.player
	for child in item_container.get_children():
		child.queue_free()
	if inventory.base.is_empty():
		for i in range(inventory.base_size):
			var item_button: Button = Button.new()
			item_button.text = tr("ui_empty_slot")
			item_container.add_child(item_button)

		return		
	for item_key: String in inventory.base:
		var item_button: Button = Button.new()
		item_button.text = inventory.base[item_key].template.display_name
		item_container.add_child(item_button)
		item_button.pressed.connect(_on_item_button_pressed.bind(item_key))


func _on_item_button_pressed(template_id: String) -> void:
	current_item = instance.base[template_id]
	update_button()
	updata_label()






func _on_close_button_pressed() -> void:
	InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)
	close()




func _on_use_button_pressed() -> void:
	if current_item == null:
		return
	match current_item.get_type():
		ItemTemplate.ItemType.EQUIPMENT:
			if current_item.is_equipped:
				player.unequip(current_item)
				updata_label()
			else:
				player.equip(current_item)
				updata_label()
			pass
		ItemTemplate.ItemType.CONSUMABLE:
			if player.use_item(current_item):
				#player.change_inventory("reduce", current_item.get_template_id())
				if current_item.quantity == 0:
					current_item = null
				update(instance)
				updata_label()
		_: print("this item can not use")
	
	SignalManager.on_player_ui_update.emit(player)
	call_deferred(&"update_button")
	

	#update_button()


func _on_delete_button_pressed() -> void:
	player.change_inventory("remove", current_item.get_template_id())
