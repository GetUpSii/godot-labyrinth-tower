extends StaticBody2D

func on_player_interact(_player: Player) -> void:
	SignalManager.on_craft_at_plot.emit("pot")
	
