extends Item
class_name Dagger


func on_player_interact(_player: Player) -> void:
	if _player.pick_up(instance):
		LevelManager.current_level.remove_obstacle(self.global_position)
		queue_free()
	##equip(_player)
	pass
