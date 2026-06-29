extends StaticBody2D
class_name BookShelf
@export var dialogue: DialogueResource
@export var dialogue_title: String
@export var type: String

var dict: Dictionary = {
	"wuno_magic_note1": ItemFactory.create_item("wuno_magic_note1"),
	"memory_potion": ItemFactory.create_item("memory_potion"),\
	"wuno_magic_note2": ItemFactory.create_item("wuno_magic_note2"),
	
}

var player: Player

func set_data(data: Dictionary) -> void:
	dialogue_title = data.get("dialogue_title")
	global_position = data.get("position")

func get_data() -> Dictionary:
	var data: Dictionary = {}
	data.set("dialogue_title", dialogue_title)
	data.set("position", global_position)
	return data


func on_player_interact(_player: Player) -> void:
	player = _player
	play_dialogue(dialogue_title)
	SignalManager.on_set_dialogue_texture.emit("")


func get_thing(_title: String) -> void:
	player.inventory.add_item(dict.get(_title))
	dialogue_title = "empty"

func play_dialogue(_title: String) -> void:
	DialogueManager.get_current_scene = func():
		return self
	SignalManager.play_dialogue_with.emit(dialogue, _title)
	#DialogueManager.show_example_dialogue_balloon(dialogue,"start")
	##disable_collision(true)
