extends PanelContainer
class_name CraftUi

@onready var craft_panel_container: PanelContainer = %CraftPanelContainer
@onready var craft_container: VBoxContainer = %CraftContainer
@onready var craft_text_label: RichTextLabel = %CraftTextLabel

@onready var delete_button: Button = %DeleteButton

@onready var craft_button: Button = %CraftButton

var current_recipe: CraftInstance
var instance: CraftSystem
var player: Player
var tool: String
## 打开库存
func open(_instance, _tool: String = "hand") -> void:	
	get_parent().layer = 0
	update(_instance)
	craft_container.get_child(0).grab_focus()
	tool = _tool
	#set_audio()
	InputManager.set_game_mode(InputManager.GameMode.DIALOGIC_MODE)
	
func close() -> void:
	#set_audio()
	get_parent().layer = -1
	queue_free()
	InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)


#
func _ready() -> void:
		# 设置PanelContainer尺寸为屏幕2/3
	self.size = Vector2(
		Global.screen_size.x * 2/3, 
		Global.screen_size.y * 2/3
	)
	self.position = (Global.screen_size - self.size) / 2
	craft_panel_container.custom_minimum_size = self.size * 1/2
	#SignalManager.on_inventory_ui_change.connect(_on_inventory_ui_change)
	

func update(_instance: CraftSystem) -> void:
	if _instance == null:
		push_error("craft system null")
		return
	if instance == null:
		instance = _instance
	if player == null:
		player = Global.player
	for child in craft_container.get_children():
		child.queue_free()
	if _instance.base.is_empty():
		for i in range(_instance.base_size):
			var _craft_button: Button = Button.new()
			_craft_button.text = tr("ui_empty_slot")
			craft_container.add_child(_craft_button)
		return		

	for craft_key: String in _instance.base:
		var _craft_button: Button = Button.new()
		_craft_button.text = instance.base[craft_key].template.display_name
		craft_container.add_child(_craft_button)
		_craft_button.pressed.connect(_on_recipe_button_pressed.bind(_instance.base[craft_key]))


func updata_label() -> void:
	craft_text_label.clear()
	if current_recipe == null:
		return
	craft_text_label.add_text(current_recipe.get_description() + "\n")
	craft_text_label.add_text(tr("craft_recipe") + "\n")
	var recipe: Dictionary = current_recipe.get_recipe()
	for item in recipe:
		craft_text_label.add_text(("%s " + tr("ui_quantity") + "%d\n") % [ItemFactory.get_template_display_name(item), recipe.get(item)])
	craft_text_label.add_text(tr("craft_result") + "%s\n" % ItemFactory.get_template_display_name(current_recipe.get_result()))
	
func _on_recipe_button_pressed(_craft_instance: CraftInstance) -> void:
	current_recipe = _craft_instance
	updata_label()


func _on_close_button_pressed() -> void:
	close()


func _on_craft_button_pressed() -> void:
	if instance.craft(player.inventory, current_recipe.get_template_id(), tool):
		LogManager.add_entry(tr("craft_success"))
	else:
		LogManager.add_entry(tr("craft_failed"))
