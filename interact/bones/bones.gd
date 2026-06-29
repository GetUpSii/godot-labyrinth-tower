extends StaticBody2D


@export var dialogue: DialogueResource
func on_player_interact(_player: Player) -> void:
	play_dialogue()

func add_inventory() -> void:
	Global.player.inventory.add_item(ItemFactory.create_item("bones"))
	queue_free()



func play_dialogue() -> void:
	DialogueManager.get_current_scene = func():
		return self
	SignalManager.play_dialogue_with.emit(dialogue, "check_bones")
	SignalManager.on_set_dialogue_texture.emit("player")
