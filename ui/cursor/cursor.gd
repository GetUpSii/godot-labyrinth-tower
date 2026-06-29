extends Node2D
@export var cell_size: Vector2 = Vector2(16, 16)
var target_pos

func to_cell_pos(pos: Vector2) -> Vector2:
	return floor(pos / Vector2(cell_size)
)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos: Vector2 = get_global_mouse_position()
		target_pos = to_cell_pos(mouse_pos) * Vector2(cell_size) + cell_size / 2
		
func _process(_delta: float) -> void:
	global_position = target_pos
