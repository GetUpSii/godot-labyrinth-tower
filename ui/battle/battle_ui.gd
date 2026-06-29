extends PanelContainer
class_name BattleUi

@onready var player_container: VBoxContainer = %PlayerContainer
@onready var enemy_container: VBoxContainer = %EnemyContainer
@onready var p_health_box: MessageBoxA = %PHealthBox
@onready var p_magic_box: MessageBoxA = %PMagicBox
@onready var p_attack_box: MessageBoxA = %PAttackBox
@onready var p_defense_box: MessageBoxA = %PDefenseBox
@onready var e_health_box: MessageBoxA = %EHealthBox
@onready var e_magic_box: MessageBoxA = %EMagicBox
@onready var e_attack_box: MessageBoxA = %EAttackBox
@onready var e_defense_box: MessageBoxA = %EDefenseBox
@onready var p_stage: Control = %PStage
@onready var e_stage: Control = %EStage
@onready var timer: Timer = $Timer

@onready var skill_v_box_container: VBoxContainer = %SkillVBoxContainer
@onready var attack_button: Button = %AttackButton
@onready var skill_button: Button = %SkillButton
@onready var prevail_button: Button = %PrevailButton
@onready var player_action_container: MarginContainer = %PlayerActionContainer

#@export var battle_switch_to_walk: GUIDEAction
var player: Player
var enemy: Character2d 
var player_stats
var enemy_stats
var is_auto: bool = true



var skills_dict: Dictionary = {}

func set_message_icon() -> void:
	p_health_box.set_texture(Global.icon_dict.get("health"))
	p_defense_box.set_texture(Global.icon_dict.get("defense"))
	p_attack_box.set_texture(Global.icon_dict.get("attack"))
	p_magic_box.set_texture(Global.icon_dict.get("magic"))
	e_health_box.set_texture(Global.icon_dict.get("health"))
	e_defense_box.set_texture(Global.icon_dict.get("defense"))
	e_attack_box.set_texture(Global.icon_dict.get("attack"))
	e_magic_box.set_texture(Global.icon_dict.get("magic"))

@onready var jump_button: Button = %JumpButton
@onready var surrender_button: Button = %SurrenderButton

func _ready() -> void:
	set_message_icon()
	
	#battle_switch_to_walk.triggered.connect(jump_battle)
	jump_button.grab_focus()
	SignalManager.on_battle_ui_focus.connect(_on_battle_ui_focus)
	


func update_enemy_ui() -> void:
	var instance_e: CharacterInstance = enemy.instance
	e_health_box.set_title(str(instance_e.current_hp)) 
	e_magic_box.set_title(str(instance_e.current_mp))
	e_attack_box.set_title(str(instance_e.get_attack()))
	e_defense_box.set_title(str(instance_e.get_defense()))		

func update_player_ui() -> void:
	var instance_p: CharacterInstance = player.instance
	p_health_box.set_title(str(instance_p.current_hp)) 
	p_magic_box.set_title(str(instance_p.current_mp))
	p_attack_box.set_title(str(instance_p.get_attack()))
	p_defense_box.set_title(str(instance_p.get_defense()))
	




func set_characters(_player: Player, _enemy: Character2d, _auto: bool = true) -> void:
	for child in p_stage.get_children():
		child.queue_free()
	for child in e_stage.get_children():
		child.queue_free()
	
	player = load(Global.play_scene).instantiate() as Player
	p_stage.add_child(player)
	enemy = load(Global.enemy_scenes.get(_enemy.instance.get_template_id())).instantiate() as Character2d
	e_stage.add_child(enemy)
	await get_tree().create_timer(0.05).timeout
	
	player.animation.scale = Vector2(4.0, 4.0)
	player.position = Vector2(30, 30)
	player.instance = _player.instance
	player.skill_system = _player.skill_system
	enemy.animation.scale = Vector2(4.0, 4.0)
	enemy.position = Vector2(30, 30)	
	enemy.instance = _enemy.instance
	enemy.skill_system = _enemy.skill_system

	for skill: SkillInstance in player.skill_system.get_skills():
		var new_button: Button = Button.new()
		skill_v_box_container.add_child(new_button)
		new_button.pressed.connect(_on_handle_skill_button_pressed.bind(skill))
		new_button.text = skill.get_display_name()
		skills_dict.set(skill, new_button)
		skill.on_skill_cooldown.connect(_on_skill_cooldown.bind(new_button))

	update_player_ui()
	update_enemy_ui()
	surrender_button.hide()
	surrender_button.disabled = true
	if enemy.instance.get_template_id() == "sorcerer":
		surrender_button.disabled = false
		surrender_button.text = tr("battle_surrender")
		surrender_button.show()
		surrender_button.pressed.connect(_surrender_battle)
		
	
	player.instance.on_character_ui_update.connect(_on_character_ui_update.bind(player.instance, true))
	enemy.instance.on_character_ui_update.connect(_on_character_ui_update.bind(enemy.instance, false))
	
	if _auto:
		is_auto = true
		BattleSystem.battle_start(player, enemy, 0.6)
	else:
		is_auto = false
		BattleSystem.battle_start(player, enemy, 0.6, false)
		player_action_container.show()
		attack_button.grab_focus()
		jump_button.hide()


func _on_character_ui_update(_type: String, instance: CharacterInstance, tag: bool) -> void:
	if !tag:
		match _type:
			"current_hp": e_health_box.set_title(str(instance.current_hp)) 
			"current_mp": e_magic_box.set_title(str(instance.current_mp))
			"attack": e_attack_box.set_title(str(instance.get_attack()))
			"defense": e_defense_box.set_title(str(instance.get_defense()))		
			_: print("there is no this attribute")
		return
	else:
		match _type:
			"current_hp": p_health_box.set_title(str(instance.current_hp)) 
			"current_mp": p_magic_box.set_title(str(instance.current_mp))
			"attack": p_attack_box.set_title(str(instance.get_attack()))
			"defense": p_defense_box.set_title(str(instance.get_defense()))		
			_: print("there is no this attribute")




func jump_battle() -> void:
	# 1. 立即结束所有定时器
	BattleSystem.set_lock_time(0.01)
	

func _surrender_battle() -> void:
	BattleSystem.current_state = BattleSystem.BATTLE_STATE.RESULT
	BattleSystem.result = BattleSystem.BATTLE_RESULT.PLAYER_LOSE
	Global.end = "surrender"
	Global.save_persist_data()
	SignalManager.end_game.emit("gd")


func _on_jump_button_pressed() -> void:
	## 检查敌人类型是不是巫师
	jump_battle()


func _on_surrender_button_pressed() -> void:
	pass # Replace with function body.



func _on_character_skill_cooldown(skill: SkillInstance) -> void:
	var button: Button = skills_dict.get(skill)
#	button.grab_focus()  # 触发焦点状态（视觉变化）
	button.modulate = Color(0.8, 0.8, 0.8)  # 变暗效果
	# 创建延迟恢复
	await get_tree().create_timer(0.1).timeout  # 100ms延迟
	# 恢复原始状态
	button.release_focus()
  #  button.modulate = Color.WHITE
#   button.emit_signal("pressed")


func _on_attack_button_pressed() -> void:
	BattleSystem.player_action_handle("attack")


func _on_skill_button_pressed() -> void:
	if skill_v_box_container.get_child_count() > 1:
		skill_v_box_container.get_child(1).grab_focus()
	

func _on_handle_skill_button_pressed(_skill: SkillInstance) -> void:
	if !is_auto:
		BattleSystem.player_action_handle("skill", _skill)
	
func _on_skill_cooldown(_v: bool, _button: Button) -> void:
	if _v:
		_button.disabled = false
	else:
		_button.disabled = true

func _on_prevail_button_pressed() -> void:
	if enemy.character_name == "fiona":	
		BattleSystem.player_action_handle("prevail")
	else:
		LogManager.add_entry(tr("battle_ignore_player"))

func _on_battle_ui_focus() -> void:
	attack_button.grab_focus()
