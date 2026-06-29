extends Item
class_name ItemCrystal




## 如果物品是药水，就直接使用
func use(_player: Player) -> void:
	instance.use("consume", _player.instance)
	SignalManager.on_player_ui_update.emit(_player)


func on_player_interact(_player: Player) -> void:
	## 检查玩家身上的库存，如果有钥匙的话就打开	print("拾取")
	use(_player)
	LogManager.add_entry(tr("log_crystal_used"))
	LevelManager.current_level.remove_obstacle(self.global_position)
	queue_free()
	pass
