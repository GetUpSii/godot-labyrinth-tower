extends Node
## 战斗结果枚举
enum BATTLE_RESULT {NULL, PLAYER_WIN, PLAYER_LOSE, PLAYER_ESCAPE, DEUCE}

enum BATTLE_STATE {IDLE, PLAYER_ATTACK, ENEMY_ATTACK, BOUNT_COUNT, ENEMY_REPLY, ANIM_PLAYING, RESULT}

var current_state = BATTLE_STATE.IDLE
var result: BATTLE_RESULT = BATTLE_RESULT.PLAYER_ESCAPE

var player: Player
var enemy: Character2d
#var battle_system: BattleSystem = BattleSystem.new()
var lock_time: float = 0.0

# 可在编辑器调整的参数 (导出变量)
static var hp_weight: float = 0.6
static var atk_weight: float = 1.8
static var level_factor: float = 0.15
static var elite_multiplier: float = 1.5

var enemy_auto_skill: Skill
var player_auto_skill: Skill

## 用于回合制游戏
var bount_count: int = 0
var is_auto: bool = true
signal on_bount_count_increased
signal on_skill_cooldown
var timer: Timer = Timer.new()

## 用于战斗信号
signal on_battle_jump_turn

## 按照回合释放技能，判断技能的冷却值
class Skill:
	var times_dict: Dictionary
	var skill_system: SkillSystem
	var target: CharacterInstance
	var bout_interval: float
	
	func _init(_skill_system: SkillSystem, _target: CharacterInstance) -> void:
		target = _target
		if _skill_system:
			skill_system = _skill_system
			set_skills_timers()
		
	
	func get_can_release_skill() -> SkillInstance:
		if skill_system == null:
			return null
		for skill: SkillInstance in skill_system.get_skills():
			if skill.can_release:
				return skill	
		return null
	
	func set_skills_timers() -> void:
		clear_skills_timers()
		for skill: SkillInstance in skill_system.get_skills():
			## set timer
			init_times(skill)

	func init_times(_skill: SkillInstance) -> void:
		var data: Array = [0, int(_skill.get_cooldown())]
		times_dict.set(_skill, data)
		
	## 释放技能会让这个技能的计数器给清零
	func release_skill(_skill: SkillInstance) -> void:
		init_times(_skill)
		_skill.can_release = false
		## 需要通知ui更新技能冷却效果
		_skill.on_skill_cooldown.emit(false)
	
	func update_skill(_skill: SkillInstance) -> void:
		_skill.can_release = true
		#print("可以释放了")
	
	## 每一回合调用此函数更新技能计数器，当计数器的指数大于冷却回合数时，将技能冷却标识置为true
	func update_timers() -> void:
		for skill: SkillInstance in times_dict:
			## 获取当前技能的冷却计数
			var count: int = times_dict.get(skill)[0]+ 1
			## 如果当前计数大于等于需要等待的冷取数
			if !skill.can_release and count > times_dict.get(skill)[1]:
				## 于是就更新当前技能的可释放状态
				update_skill(skill)
				skill.on_skill_cooldown.emit(true)
			else:
				times_dict.get(skill)[0] = count
	## 清理技能计数器
	func clear_skills_timers() -> void:
		refurbish_skill()
		times_dict.clear()
		
	
	func refurbish_skill() -> void:
		if skill_system == null:
			return	
		for skill: SkillInstance in skill_system.get_skills():
			skill.can_release = true




func turn_count() -> void:
	bount_count += 1
	on_bount_count_increased.emit()
	LogManager.add_entry(tr("battle_round_end") % bount_count)



func _ready() -> void:
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	on_battle_jump_turn.connect(_on_battle_jump_turn)

var player_jump_state: bool = false
var enemy_jump_state: bool = false
func _on_battle_jump_turn(_player_jump: bool = true) -> void:
	if _player_jump:
		player_jump_state = true
	else:
		enemy_jump_state = true

func random_first() -> void:
	var player_first = randf() < 0.5
	if player_first:
		current_state = BATTLE_STATE.PLAYER_ATTACK
	else:
		current_state = BATTLE_STATE.ENEMY_ATTACK
	LogManager.add_entry(tr("battle_round_start") % 1)
	

func battle_start(_player: Player, _enemy: Character2d, _timer: float, _auto: bool = true) -> void:
	# 决定先手（玩家有50%概率获得先手）
	player = _player
	enemy = _enemy
	random_first()
	if not player or not enemy:
		push_error("Invalid battle participants")
		current_state = BATTLE_STATE.RESULT
		result = BATTLE_RESULT.NULL
		return
	SignalManager.on_change_audio_background.emit("battle")
	enemy_auto_skill = Skill.new(enemy.skill_system, player.instance)
	player_auto_skill = Skill.new(player.skill_system, enemy.instance)
	is_auto = _auto
	timer.start(_timer)
	#_on_timer_timeout()

var prevail_count: int = 0
var current_prevail: PREVAIL = PREVAIL.NULL

enum PREVAIL{
	NULL,
	USE_RING,
	USE_HEART,
	MEMORY_1,
	MEMORY_2,
}
func player_action_handle(_type: String, _skill: SkillInstance = null) -> void:
	if current_state != BATTLE_STATE.PLAYER_ATTACK and provisional_state != BATTLE_STATE.PLAYER_ATTACK:
		return
	if player_jump_state:
		return
	match _type:
		"attack":
			do_normal_attack(player.instance, enemy.instance)
			provisional_state = BATTLE_STATE.ENEMY_ATTACK
			current_state = BATTLE_STATE.BOUNT_COUNT
		"skill":
			if try_skill_attack(player, enemy.instance, player_auto_skill, _skill):
			## 等待释放完技能
				provisional_state = BATTLE_STATE.ENEMY_ATTACK
				current_state = BATTLE_STATE.BOUNT_COUNT
		"prevail":
			match current_prevail:
				PREVAIL.NULL:
					if Global.player.check_inventory("lover_ring"):
						prevail_count += 1	
						current_prevail = PREVAIL.USE_RING
						handle_prevail(true)
					else:
						handle_prevail(false)
				PREVAIL.USE_RING:
					if Global.player.check_inventory("eternal_heart"):
						prevail_count += 1
						current_prevail = PREVAIL.USE_HEART
						handle_prevail(true)
					else:
						handle_prevail(false)

				PREVAIL.USE_HEART:
					if Global.memory >= 1:
						prevail_count += 1
						current_prevail = PREVAIL.MEMORY_1
						handle_prevail(true)
					else:
						handle_prevail(false)
					
				PREVAIL.MEMORY_1:
					if Global.memory >= 2:
						prevail_count += 1
						current_prevail = PREVAIL.MEMORY_2
						handle_prevail(true)
					else:
						handle_prevail(false)
				PREVAIL.MEMORY_2:
					pass
			## 判断有没有
			## 如果有恋人的戒指
			
		_:
			pass


func handle_prevail(succeed: bool = false) -> void:
	if !succeed:
		SignalManager.play_dialogue_with.emit(load("res://resource/dialogue/brave.dialogue"), "prevail_fail")
		
		await DialogueManager.dialogue_ended
		
		SignalManager.on_battle_ui_focus.emit()
		provisional_state = BATTLE_STATE.ENEMY_ATTACK
		current_state = BATTLE_STATE.BOUNT_COUNT
	else:
		Global.set_npc_dialogue_title("fiona", "ch" + str(prevail_count))
		
		SignalManager.play_dialogue_with.emit(load("res://resource/dialogue/fiona.dialogue"), Global.get_dialogue_title("fiona"))
		await DialogueManager.dialogue_ended
		SignalManager.on_battle_ui_focus.emit()
		InputManager.set_game_mode(InputManager.GameMode.DIALOGIC_MODE)
		if prevail_count >= 4:
			finish_battle()
			return
		provisional_state = BATTLE_STATE.PLAYER_ATTACK
		current_state = BATTLE_STATE.BOUNT_COUNT


func finish_battle() -> void:
	result = BATTLE_RESULT.DEUCE
		# 处理战斗结果
	player_auto_skill.clear_skills_timers()
	enemy_auto_skill.clear_skills_timers()
	if EffectExecutor:
		if EffectExecutor.burn_effect:
			EffectExecutor.burn_effect.clear()
	timer.stop()
	
	bount_count = 0
	
	SignalManager.on_change_audio_background.emit("default")
	SignalManager.on_auto_battle_finished.emit(result)

func jump_turnt() -> void:
	if player_jump_state:
		provisional_state = BATTLE_STATE.ENEMY_ATTACK
		current_state = BATTLE_STATE.BOUNT_COUNT
		player_jump_state = false

var provisional_state: BATTLE_STATE = BATTLE_STATE.IDLE
func _on_timer_timeout() -> void:
	if player.instance.current_hp <= 0:
		result = BATTLE_RESULT.PLAYER_LOSE	
		current_state = BATTLE_STATE.RESULT
	elif enemy.instance.current_hp <= 0:
		result = BATTLE_RESULT.PLAYER_WIN
		current_state = BATTLE_STATE.RESULT
	
	match current_state:
		BATTLE_STATE.PLAYER_ATTACK:
			if player_jump_state:
				provisional_state = BATTLE_STATE.ENEMY_ATTACK
				current_state = BATTLE_STATE.BOUNT_COUNT
				player_jump_state = false
				return
			if is_auto:
				auto_handle(player, enemy, player_auto_skill)
				provisional_state = BATTLE_STATE.ENEMY_ATTACK
				current_state = BATTLE_STATE.BOUNT_COUNT
		BATTLE_STATE.BOUNT_COUNT:
			## 更新一下技能的冷却回合
			turn_count()
			enemy_auto_skill.update_timers()
			player_auto_skill.update_timers()
			current_state = provisional_state
		BATTLE_STATE.ENEMY_ATTACK:
			if enemy_jump_state:
				provisional_state = BATTLE_STATE.PLAYER_ATTACK
				current_state = BATTLE_STATE.BOUNT_COUNT
				enemy_jump_state = false
				return
			auto_handle(enemy, player, enemy_auto_skill)
			provisional_state = BATTLE_STATE.PLAYER_ATTACK
			current_state = BATTLE_STATE.BOUNT_COUNT
		BATTLE_STATE.ENEMY_REPLY:

				pass
		BATTLE_STATE.RESULT:
			# 处理战斗结果
			player_auto_skill.clear_skills_timers()
			enemy_auto_skill.clear_skills_timers()
			if EffectExecutor.burn_effect:
				EffectExecutor.burn_effect.clear()
			timer.stop()
			bount_count = 0
			InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)
			SignalManager.on_change_audio_background.emit("default")
			SignalManager.on_auto_battle_finished.emit(result)
			
## 自动攻击的时候会检测队列中有没有技能
## 如果有技能就开启定时器，用于检测冷却时间，因为是回合制所以以回合计算，相当于是五个回合，也就是一次lock_time
## 如果冷却时间到了就进行技能效果调用
# 自动战斗情况判断，如果技能可以释放就是放
func auto_handle(_attacker, _target, _autoskill: Skill) -> void:
	var attack_instance: CharacterInstance = _attacker.instance
	var target_instance: CharacterInstance = _target.instance
	if try_skill_attack(_attacker, target_instance, _autoskill):
		return 
	do_normal_attack(attack_instance, target_instance)

## 尝试释放技能
func try_skill_attack(_attacker: Character2d, _target, _skill_handle: Skill, _skill: SkillInstance = null) -> bool:
	
	var skill: SkillInstance 
	if _skill == null:
		skill = _skill_handle.get_can_release_skill()
		if skill == null:
			return false
	else:
		skill = _skill
	if _attacker.instance.release_magic(skill.get_mana()):
		LogManager.add_entry(tr("battle_skill_cast") % [_attacker.instance.get_diplay_name(), skill.get_display_name()])
		skill.trigger(_attacker.instance, _target)
		_skill_handle.release_skill(skill)
		_attacker.play_animation_with(skill.get_template_id(), true)
		return	true
	return false

## 普通攻击
func do_normal_attack(_attacker: CharacterInstance, _target: CharacterInstance) -> void:
	var damage = _calculate_damage(_attacker, _target)
	_target.get_damage(damage)
	LogManager.add_entry(tr("battle_damage_dealt") % [_attacker.get_diplay_name(), _target.get_diplay_name(), damage])
	update_animation_ui(_attacker.get_template_id(), "hit")
	update_animation_ui(_target.get_template_id(), "hurt")

## 更新ui
func update_animation_ui(_type: String, animation: String) -> void:
	if _type == "player1":
		player.play_animation_with(animation)
	else:
		enemy.play_animation_with(animation)






## 计算部分
func calculate_reward_exp(_player_instance: CharacterInstance, _enemy_instance: CharacterInstance) -> int:
	var base_exp = calculate_exp(_enemy_instance)

	# 应用等级差修正
	var level_diff = _player_instance.level - _enemy_instance.level
	var exp_multiplier = 1.0
	
	if level_diff > 5:  # 比敌人高5级以上，经验减少
		exp_multiplier = max(0.2, 1.0 - (level_diff - 5) * 0.1)
	elif level_diff < -3:  # 比敌人低3级以上，经验增加
		exp_multiplier = 1.0 + abs(level_diff) * 0.15
	var exp_reward = int(base_exp * exp_multiplier)
	return exp_reward


func calculate_reward_gold(_player_instance: CharacterInstance, _enemy_instance: CharacterInstance) -> int:
	var gold_reward = int(_enemy_instance.template.base_hp * 0.1 + _enemy_instance.template.base_attack * 0.5)
	return gold_reward
# 击败敌人并获取奖励
func calculate_reward(_player_instance: CharacterInstance, _enemy_instance: CharacterInstance, pool_name: String) -> Dictionary:
	# 计算基础经验奖励（基于敌人等级和模板）
	var exp_reward: int = calculate_reward_exp(_player_instance, _enemy_instance)
	# 计算金币奖励
	var gold_reward: int = calculate_reward_gold(_player_instance, _enemy_instance)
	var loot: ItemInstance = LootPool.get_loot(pool_name)

	return {
		"exp": exp_reward,
		"gold": gold_reward,
		"item": [loot,]
	}
	
# 核心计算函数
static func calculate_exp(_enemy_instance: CharacterInstance) -> int:
	var base_value: float = (
		_enemy_instance.template.base_hp * hp_weight
		+ _enemy_instance.template.base_attack * atk_weight
	)
	
	var level_bonus: float = 1.0 + sqrt(_enemy_instance.level) * level_factor
	var total_exp: float = base_value * level_bonus
	# 随机浮动±10%
	total_exp *= randf_range(0.9, 1.1)
	return int(total_exp)


## 魔塔战斗公式
static var DAMAGE_FORMULA = {
	"basic": func(_attacker, _defender):
		return max(_attacker.get_attack() - _defender.get_defense(), 0),
	
	"percentage": func(_attacker, _defender, _percent: float = 0.1):
		return max(int(_attacker.attack * _percent), 1),
	
	"fixed": func(_attacker, _defender, _fixed_damage: int = 100):
		return _fixed_damage
}



## 伤害计算
static func _calculate_damage(attacker, defender, damage_type: String = "") -> int:
	match damage_type:
		"percentage":
			return DAMAGE_FORMULA.percentage.call(attacker, defender)
		"fixed":
			return DAMAGE_FORMULA.fixed.call(attacker, defender)
		_: # "basic" 或其他
			return DAMAGE_FORMULA.basic.call(attacker, defender)

func set_lock_time(_timer: float) -> void:
	timer.wait_time = _timer
	enemy_auto_skill.bout_interval = _timer
	player_auto_skill.bout_interval = _timer
	
