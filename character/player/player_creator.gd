extends Node2D
class_name PlayerCreator
var player: Player

func initialize(_player) -> void:
	player = _player
	player.initialize()
	SignalManager.on_player_ui_update.emit(player)





#func update_ui() -> void:
	#SignalManager.on_player_ui_update.emit(player)
	#pass
