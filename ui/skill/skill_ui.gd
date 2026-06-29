extends PanelContainer
class_name SkillUi
@onready var skill_container: VBoxContainer = %SkillContainer

@onready var skill_text_label: RichTextLabel = %SkillTextLabel
@onready var skill_panel_container: PanelContainer = %SkillPanelContainer

var current_skill: SkillInstance
var instance: SkillSystem
var player: Player

## 打开库存
func open(_instance) -> void:	
	get_parent().layer = 0
	update(_instance)
	skill_container.get_child(0).grab_focus()
	#set_audio()
	
func close() -> void:
	#set_audio()
	get_parent().layer = -1
	queue_free()


#
func _ready() -> void:
		# 设置PanelContainer尺寸为屏幕2/3
	self.size = Vector2(
		Global.screen_size.x * 2/3, 
		Global.screen_size.y * 2/3
	)
	self.position = (Global.screen_size - self.size) / 2
	skill_panel_container.custom_minimum_size = self.size * 1/2
	#SignalManager.on_inventory_ui_change.connect(_on_inventory_ui_change)
	

func update(_instance: SkillSystem) -> void:
	if _instance == null:
		push_error("skll system null")
		return
	if instance == null:
		instance = _instance
	if player == null:
		player = Global.player
	for child in skill_container.get_children():
		child.queue_free()
	if _instance.base.is_empty():
		for i in range(_instance.base_size):
			var skill_button: Button = Button.new()
			skill_button.text = "空的"
			skill_container.add_child(skill_button)

		return		
	for skill_key: String in _instance.base:
		var skill_button: Button = Button.new()
		skill_button.text = instance.base[skill_key].template.display_name
		skill_container.add_child(skill_button)
		skill_button.pressed.connect(_on_skill_button_pressed.bind(_instance.base[skill_key]))


func updata_label() -> void:
	skill_text_label.clear()
	if current_skill == null:
		return
	skill_text_label.add_text(current_skill.get_description() + "\n")

	
func _on_skill_button_pressed(_skill_instance: SkillInstance) -> void:
	current_skill = _skill_instance
	updata_label()


func _on_close_button_pressed() -> void:
	close()
