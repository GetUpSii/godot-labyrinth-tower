extends Area2D
class_name Trap
@onready var sprite_2d: Sprite2D = $Sprite2D
var show_status: bool = false:
	set(v):
		show_status = v
		if !show_status:
			set_deferred("monitoring", true)
			if sprite_2d == null:
				await ready
			sprite_2d.visible = false
		else:
			set_deferred("monitoring", false)
			if sprite_2d == null:
				await ready
			sprite_2d.visible = true			

func _ready() -> void:
	SignalManager.on_revealing_potion_use.connect(_on_revealing_potion_use)
	add_to_group(&'trap')
	
func get_data() -> Dictionary:
	var data: Dictionary = {}
	data.set("status", show_status)
	data.set("position", global_position)
	return data

func set_data(data: Dictionary) -> void:
	show_status = data.get("status")
	global_position = data.get("position")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		show_status = true
		body.instance.get_damage(50)
		body.play_animation_with("hurt")
		SignalManager.on_player_ui_update.emit(body)
		if body.instance.current_hp <= 0:
			SignalManager.end_game.emit()

func _on_revealing_potion_use() -> void:
	show_status = true
	
