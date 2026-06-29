extends HBoxContainer

@onready var node_2d: Node2D = $Node2D


func _on_button_pressed() -> void:
	CharacterFactory.initialize()
	if CharacterFactory.get_template("ghost"):
		print("人物模板初始化完成")	
	SkillFactory.initialize()
	if SkillFactory.get_template("fileball"):
		print("技能模板初始化完成")	
	
func _on_button_2_pressed() -> void:
	var fire_ball: SkillInstance = SkillFactory.create_skill("fireball")
	var player: Player = load("res://character/player/player.tscn").instantiate() as Player
	player.initialize()
	node_2d.add_child(player)
	get_tree().create_timer(0.05).timeout
	fire_ball.trigger(player.instance)
