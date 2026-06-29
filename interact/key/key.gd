extends Item
class_name ItemKey


func on_player_interact(_player: Player) -> void:
	## 检查玩家身上的库存，如果有钥匙的话就打开	print("拾取")
	#InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)
	
	if _player.pick_up(instance):
		LevelManager.current_level.remove_obstacle(self.global_position)
		SignalManager.on_player_ui_update.emit(_player)
		SignalManager.on_change_audio_effect.emit("key")
		
		queue_free()
	#InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)
	
