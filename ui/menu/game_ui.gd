extends Control

@onready var health_box: MessageBoxA = %HealthBox
@onready var magic_box: MessageBoxA = %MagicBox
@onready var attack_box: MessageBoxA = %AttackBox
@onready var defence_box: MessageBoxA = %DefenceBox
@onready var gold_box: MessageBoxA = %GoldBox
@onready var yellow_key_box: MessageBoxA = $LeftContianer/MarginContainer/VBoxContainer/YellowKeyBox
@onready var blue_key_box: MessageBoxA = $LeftContianer/MarginContainer/VBoxContainer/BlueKeyBox
@onready var red_key_box: MessageBoxA = $LeftContianer/MarginContainer/VBoxContainer/RedKeyBox
@onready var player_level_box: MessageBoxA = $LeftContianer/MarginContainer/VBoxContainer/PlayerLevelBox
@onready var level_title: Label = %LevelTitle

@onready var bag_button: Button = %BagButton
@onready var setting_button: Button = %SettingButton


signal button_pressed
var health: int:
	set(v):
		health = v
		health_box.set_title(str(health))

var magic: int:
	set(v):
		magic = v
		magic_box.set_title(str(magic))	

var attack: int:
	set(v):
		attack = v
		attack_box.set_title(str(attack))	

var defence: int:
	set(v):
		defence = v
		defence_box.set_title(str(defence))

var gold: int:
	set(v):
		gold = v
		gold_box.set_title(str(gold))

var yellow_key: int:
	set(v):
		yellow_key = v
		yellow_key_box.set_title(str(yellow_key))

var blue_key: int:
	set(v):
		blue_key = v
		blue_key_box.set_title(str(blue_key))

var red_key: int:
	set(v):
		red_key = v
		red_key_box.set_title(str(red_key))

var player_level: int:
	set(v):
		player_level = v
		player_level_box.set_title(tr("ui_level") + " " + str(player_level))
		




func _ready() -> void:
	SignalManager.on_player_ui_update.connect(_on_player_ui_update)
	SignalManager.on_map_level_change.connect(_on_map_level_change)
	bag_button.pressed.connect(_on_bag_button_pressed)
	setting_button.pressed.connect(_on_setting_button_pressed)
	magic_box.set_texture(Global.icon_dict["magic"])
	health_box.set_texture(Global.icon_dict["health"])
	attack_box.set_texture(Global.icon_dict["attack"])
	defence_box.set_texture(Global.icon_dict["defense"])
	gold_box.set_texture(Global.icon_dict["gold"])
	yellow_key_box.set_texture(Global.icon_dict["yellow_key"])
	blue_key_box.set_texture(Global.icon_dict["blue_key"])
	red_key_box.set_texture(Global.icon_dict["red_key"])
	player_level_box.set_texture(Global.icon_dict["player"])


func update_key(player: Player, key_type: String) -> int:
	var key_instance = player.check_inventory(key_type)
	if key_instance == null:
		return 0
	return key_instance.quantity	
	
func _on_player_ui_update(player: Player) -> void:
	var instance: CharacterInstance = player.instance
	health = instance.get_current_hp()
	magic = instance.get_current_mp()
	attack = instance.get_attack()
	defence = instance.get_defense()
	player_level = instance.level	
	
	yellow_key = update_key(player, "yellow_key")
	blue_key = update_key(player, "blue_key")
	red_key = update_key(player, "red_key")
	
	if player.inventory:
		gold = player.inventory.gold
	else:
		push_error("empty bag for player !")

func _on_map_level_change(level_id: int) -> void:
	level_title.text = tr("ui_hud_floor") % level_id

func _on_bag_button_pressed() -> void:
	button_pressed.emit("bag")

	
func _on_setting_button_pressed() -> void:
	button_pressed.emit("setting")


func _on_skill_button_pressed() -> void:
	button_pressed.emit("skill")


func _on_craft_button_pressed() -> void:
	button_pressed.emit("craft")
