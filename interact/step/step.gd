extends Area2D
class_name Step
@export var type: String

#func _ready() -> void:
	#add_to_group(&'down_step')




func _on_body_entered(body: Node2D) -> void:
	if body is Player and !LevelManager.level_changing:
		# 切换后的第一次触发无效（玩家刚传送过来站在楼梯上）
		if LevelManager._just_teleported:
			LevelManager._just_teleported = false
			return
		var player: Player = body
		if type == "up_step":
			LevelManager.up_level(player)
		elif type == "down_step":
			LevelManager.down_level(player)
	else:
		LevelManager.level_changing = false
		LevelManager._just_teleported = false
