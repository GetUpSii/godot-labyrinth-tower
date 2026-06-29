extends StaticBody2D
class_name SecretStep
@export var type: String
@onready var sprite_2d_2: Sprite2D = $Sprite2D2
var show_status: bool = false:
	set(v):
		show_status = v
		if show_status:
			if sprite_2d_2 == null:
				await ready
			sprite_2d_2.visible = true
		else:
			if sprite_2d_2 == null:
				await ready
			sprite_2d_2.visible = false
		

func _ready() -> void:
	SignalManager.on_revealing_potion_use.connect(_on_revealing_potion_use)
	if type == "down_step":
		show_status = true

func set_data(data: Dictionary) -> void:
	type = data.get("type")
	show_status = data.get("status")
	global_position = data.get("position")

func get_data() -> Dictionary:
	var data: Dictionary = {}
	data.set("type", type)
	data.set("status", show_status)
	data.set("position", global_position)
	return data

func on_player_interact(_player: Player) -> void:
	if !show_status:
		return
	if !LevelManager.level_changing:
		#LevelManager.current_level.remove_obstacle(self.global_position)
		print("player entered, change map to level +1")
		if type == "up_step":
			LevelManager.up_secret_room(_player)
		else:
			LevelManager.down_secret_room(_player)
	else:
		LevelManager.level_changing = false

func _on_revealing_potion_use() -> void:
	show_status = true
