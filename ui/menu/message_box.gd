extends  MarginContainer
class_name MessageBoxA

@onready var texture_rect: TextureRect = $HBoxContainer/Texture
@onready var label: Label = $HBoxContainer/Label


func set_texture(texture: Texture2D) -> void:
	texture_rect.texture = texture
	
func set_title(title: String) -> void:
	label.text = title
