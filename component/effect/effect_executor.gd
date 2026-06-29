extends Node
#class_name EffectExecutor
# 注册效果处理器
var _handlers: Dictionary = {
	"stats_attack_up": _handle_stats_attack_up,
	"stats_denfense_up": _handle_stats_denfense_up,
	"heal_hp": _handle_heal_hp,
	"suck_blood": _handle_suck_blood,
	"heal_mp": _handle_heal_mp,
	"modify_stat": _handle_modify_stat,
	"mana_damage": _handle_mana_damage,
	"burn": _handle_burn_damage,
	"revealing": _handle_revealing,
	"learn": _handle_learn,
	"restore_memory": _handle_restore_memory,
	"double_health": _handle_double_health,
	"frozen": _handle_frozen,
	"nihilization": _handle_nihilization,
	"vertigo": _handle_vertigo,
	"attack_power": _handle_attack_power,
	"combo": _handle_attack_combo
	
	#"un_modify_stat": _handle_un_modify_stat
}


	# 执行效果
func apply_effects(effects: Array, user: CharacterInstance) -> void:
	for effect in effects:
		var handler = _handlers.get(effect.type)
		if handler:
			handler.call(effect.params, user)
		else:
			push_error("未知效果类型: " + effect.type)

func apply_single_effect(effect: EffectDescriptor, _target: CharacterInstance, _user: CharacterInstance = null) -> void:
	var type: String = effect.type
	var handler = _handlers.get(type)
	if handler:
		if _user:
			handler.call(effect.params, _target, _user)
			return
		handler.call(effect.params, _target)
	else:
		push_error("未知效果类型: " + effect.type)

func apply_single_effect_dict(effect: Dictionary, user: CharacterInstance) -> void:
	var type: String = effect.get("type")
	var handler = _handlers.get(type)
	if handler:
		handler.call(effect, user)
	else:
		push_error("未知效果类型: " + type)


func unapply_effects(effects: Array, user: CharacterInstance) -> void:
	for effect in effects:
		_handle_un_modify_stat(effect.params, user)

#===== 具体效果处理器 =====
func _handle_heal_hp(params: Dictionary, target: CharacterInstance) -> void:
	var value = params.get("value", 0)
	LogManager.add_entry(tr("effect_heal_hp") % value)
	# 调用角色的治疗接口
	target.heal_hp(value)
	# 显示治疗特效

func _handle_suck_blood(params: Dictionary, target: CharacterInstance, user: CharacterInstance) -> void:
	var value: float = params.get("value", 0)
	var damage: int = user.get_attack() - target.get_defense()
	var heal_hp: int = int(value * damage)
	if damage > 0:
		target.get_damage(damage)
		user.heal_hp(heal_hp)
		LogManager.add_entry(tr("effect_take_damage") % [target.get_diplay_name(), damage])
		LogManager.add_entry(tr("effect_blood_drain") % [user.get_diplay_name(), target.get_diplay_name(), heal_hp])
	# 调用角色的治疗接口
	
	# 显示治疗特效

func _handle_heal_mp(params: Dictionary, target: CharacterInstance) -> void:
	var value: int = int(params.get("value", 0))
	LogManager.add_entry(tr("effect_heal_mp") % value)
	target.heal_mp(value)
	# 显示治疗特效
## 处理属性增长（主要处理的是水晶的）
func _handle_stats_attack_up(params: Dictionary, target: CharacterInstance) -> void:
	var value = params.get("value", 0)
	LogManager.add_entry(tr("effect_attack_up") % value)
	
func _handle_stats_denfense_up(params: Dictionary, target: CharacterInstance) -> void:
	var value = params.get("value", 0)
	LogManager.add_entry(tr("effect_defense_up") % value)
	
## 处理属性修改器
func _handle_modify_stat(params: Dictionary, target: CharacterInstance) -> void:
	var stat = params.get("stat")
	var value = params.get("value", 0)
	var mod_type = params.get("mod_type", "flat")
	#var duration = params.get("duration", 0)  # 0表示永久
	var modifier_id = params.get("unique_id")
	var duration: float
	if params.has("duration"):
		duration = params.get("duration", -1) 
		if duration == 0:
			params.set("type", "modify_stat")
			target.buff.append(params)
	
	# 使用属性修改器系统
	target.modifier_system.add_modifier(stat, modifier_id, {
		"type": mod_type, 
		"value": value
	})




func _handle_un_modify_stat(params: Dictionary , target: CharacterInstance) -> void:
	target.modifier_system.remove_modifier(params.get("stat"), params.get("unique_id"))

func _handle_nihilization(_params: Dictionary , _target: CharacterInstance) -> void:
	pass
	
func _handle_vertigo(params: Dictionary ,_target: CharacterInstance, _user: CharacterInstance = null) -> void:
	if ProbabilitySystem.check_probability(params.get("probability")):
		LogManager.add_entry(tr("effect_stunned") % _target.get_diplay_name())
		if _target.get_template_id() == "player1":
			BattleSystem.on_battle_jump_turn.emit()
		else:
			BattleSystem.on_battle_jump_turn.emit(false)

func _handle_attack_power(params: Dictionary, _target: CharacterInstance, _user: CharacterInstance) -> void:
	var value: float = params.get("value")
	var attack: int = int(value * _user.get_attack())
	var damage: int = attack - _target.get_defense()
	_target.get_damage(damage)
	LogManager.add_entry(tr("effect_take_damage") % [_target.get_diplay_name(), damage])

var combo_probability: float = 1.0
func _handle_attack_combo(params: Dictionary, _target: CharacterInstance, _user: CharacterInstance) -> void:
	var probability: float = params.get("probability")
	var attack: int = int(probability * _user.get_attack())
	var damage: int = attack - _target.get_defense()
	if ProbabilitySystem.check_probability(combo_probability) and combo_probability > 0.2:
		combo_probability -= 0.2
		_target.get_damage(damage)
		LogManager.add_entry(tr("effect_frost_combo") % [_user.get_diplay_name(), _target.get_diplay_name(), damage])
		frozen_count += 1
		LogManager.add_entry(tr("effect_frost_stack_add") % [_target.get_diplay_name()])
		_handle_attack_combo(params, _target, _user)
	else:
		combo_probability = 1.0


## 魔法攻击将无视物理防御
func _handle_mana_damage(params: Dictionary , target: CharacterInstance) -> void:
	var value: int = params.get("value")
	LogManager.add_entry(tr("effect_magic_damage") % [target.get_diplay_name(), value]  )
	target.get_damage(value)


func _handle_revealing(_effect: Dictionary, _target: CharacterInstance) -> void:
	SignalManager.on_revealing_potion_use.emit()

func _handle_learn(params: Dictionary, _target: CharacterInstance) -> void:
	var skill: SkillInstance = SkillFactory.create_skill(params.get("skill"))
	SignalManager.on_player_learn_skill.emit(skill)

func _handle_restore_memory(_params: Dictionary, _target: CharacterInstance) -> void:
	var dialogue: DialogueResource = load('res://resource/dialogue/brave.dialogue')
	Global.memory += 1
	Global.load_persist_data()
	Global.save_persist_data()
	# 始终依次播放 memory1, memory2, memory3（封顶3个）
	DialogueManager.get_current_scene = func():
		return self
	var max_dialogue: int = mini(Global.memory, 3)
	var sequence: Array = []
	for i in range(1, max_dialogue + 1):
		sequence.append([dialogue, "memory" + str(i)])
	SequenceDialoguePlayer.play_sequence(sequence)
	# 超过3则封顶
	if Global.memory > 3:
		Global.memory = 4

## 用于回合制的效果计数
class EffectCount:
	var effect_dict: Dictionary
	## 初始化
	func _init() -> void:
		BattleSystem.on_bount_count_increased.connect(_on_bount_count_increased)
	func add_effect(_unique_id: String, _total: int, _type: String, _value: int,  _target: CharacterInstance) -> void:
		effect_dict.set(_unique_id, {
				"count": 0,
				"total": _total,
				"type": _type,
				"value": _value,
				"target": _target
			})
	func update_effect() -> void:
		for id in effect_dict:
			var count: int = effect_dict.get(id).get("count")
			var total: int = effect_dict.get(id).get("total")
			count += 1
			## 如果计数达到就移除效果
			if count > total:
				remove_effect(id)
				continue
			## 否则更新计数
			effect_dict.get(id).set("count", count)
			## 并根据类型来进行操作
			if effect_dict.get(id).get("type") == "damage":
				damage(id, effect_dict.get(id).get("value") )

	func remove_effect(_id) -> void:
		effect_dict.erase(_id)
	
	func clear() -> void:
		effect_dict.clear()
	
	func _on_bount_count_increased() -> void:
		update_effect()

	func damage(_id: String, _v: int) -> void:
		var target: CharacterInstance = effect_dict.get(_id).get("target")
		target.get_damage(_v)
		LogManager.add_entry(tr("effect_burn_tick") % [target.get_diplay_name(), _v])
	

var burn_effect: EffectCount

## 这个将会持续一段时间一直造成伤害
func _handle_burn_damage(params: Dictionary , target: CharacterInstance) -> void:
	var interval: float = params.get("interval")
	var modifier_id: String = params.get("unique_id")
	var duration: float = params.get("duration")
	var value: int = params.get("value")
	var burn_count = duration / interval
	if !burn_effect:
		burn_effect = EffectCount.new()
	LogManager.add_entry(tr("effect_burn_gained") % target.get_diplay_name())
	burn_effect.add_effect(modifier_id, burn_count, "damage", value, target)
	
	
func _handle_double_health(_params: Dictionary , _target: CharacterInstance) -> void:
	_target.current_hp = _target.current_hp * 2
	SignalManager.on_player_ui_update.emit(Global.player)


var frozen_count: int = 0
## 冻结效果，不受到伤害，但是会叠加层数，一旦层数到达，玩家将会减少
func _handle_frozen(params: Dictionary , target: CharacterInstance, _user: CharacterInstance = null) -> void:
	var interval: float = params.get("interval")
	var modifier_id: String = params.get("unique_id")
	var value: int = params.get("value")
	## 我想写个回调函数绑定BattleSystem里面回合更新的信号，怎么写
	LogManager.add_entry(tr("effect_frost_stacks_add") % [target.get_diplay_name(), value])
	frozen_count += value
	if !BattleSystem.on_bount_count_increased.is_connected(_on_bount_count_increased):
		BattleSystem.on_bount_count_increased.connect(_on_bount_count_increased)


func _on_bount_count_increased() -> void:
	print("当前冰冻层数", frozen_count)
	frozen_count -= 1
	LogManager.add_entry(tr("effect_frost_decay"))
	if frozen_count >= 5:
		frozen_count = 0
		BattleSystem.on_bount_count_increased.disconnect(_on_bount_count_increased)
		LogManager.add_entry(tr("effect_frost_5_skip"))
		
		BattleSystem.on_battle_jump_turn.emit()
