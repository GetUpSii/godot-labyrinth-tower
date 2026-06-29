extends StaticBody2D
class_name Door
@export var require_item: String
@export var type: String
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var locked: bool = true:
	set(v):
		locked = v
		unlock()
		
func unlock() -> void:
	if collision_shape_2d == null:
		await ready
	if !locked:
		collision_shape_2d.disabled = true
		modulate = Color.GRAY

func set_audio() -> void:
	SignalManager.on_change_audio_effect.emit("door")
	pass



func get_data() -> Dictionary:
	var door_data: Dictionary = {}
	door_data["locked"] = locked
	door_data["position"] = global_position
	door_data["type"] = type
	
	return door_data



func on_player_interact(_player: Player) -> void:
	## 检查玩家身上的库存，如果有钥匙的话就打开	print("拾取")
	if _player.check_inventory(require_item):
		if _player.change_inventory("reduce", require_item):
			locked = false
			set_audio()
			if type == "white_door":
				if Global.get_die("fiona"):
					SignalManager.end_game.emit("he")
				else:
					SignalManager.end_game.emit("te")
				return
			LevelManager.current_level.remove_obstacle(self.global_position)
			LogManager.add_entry(tr("log_door_opened"))
	else:
		LogManager.add_entry(tr("log_missing_key"))
	
