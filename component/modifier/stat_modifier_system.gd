# stat_modifier_system.gd
class_name StatModifierSystem
extends RefCounted


## 这部分后期改成组件，绑定到每个人物场景？因为持续性效果无法在这里处理

# 属性修改器存储结构
var _stat_modifiers: Dictionary = {}
var _modified_stats: Dictionary = {}
var _stat_base_values: Dictionary = {}
var _stat_update_callbacks: Dictionary = {}

# 初始化系统
func _init(supported_stats: Array) -> void:
	for stat in supported_stats:
		_stat_modifiers[stat] = {}
		_modified_stats[stat] = 0
		_stat_base_values[stat] = 0
		_stat_update_callbacks[stat] = []

# 添加属性修改器
func add_modifier(stat: String, modifier_id: String, modifier_data: Dictionary) -> void:
	# 验证属性有效性
	if not _stat_modifiers.has(stat):
		push_error("属性 %s 不受支持" % stat)
		return
	
	# 确保修改器ID唯一
	if _stat_modifiers[stat].has(modifier_id):
		return
	
	# 添加修改器
	_stat_modifiers[stat][modifier_id] = modifier_data
	_update_stat(stat)
	



# 移除属性修改器
func remove_modifier(stat: String, modifier_id: String) -> void:
	# 检查属性是否存在
	if not _stat_modifiers.has(stat):
		push_warning("尝试从未定义的属性 %s 中移除修改器" % stat)
		return
	
	# 检查修改器是否存在
	if not _stat_modifiers[stat].has(modifier_id):
		push_warning("尝试移除不存在的修改器: %s" % modifier_id)
		return
	
	# 移除修改器
	_stat_modifiers[stat].erase(modifier_id)
	
	## 清理空属性字典
	#if _stat_modifiers[stat].is_empty():
		#_stat_modifiers.erase(stat)
	
	_update_stat(stat)

# 设置基础值（由拥有者设置）
func set_base_value(stat: String, value: int) -> void:
	if _stat_base_values.has(stat):
		_stat_base_values[stat] = value
		_update_stat(stat)

# 获取最终值（包含基础值和所有修改）
func get_final_value(stat: String) -> int:
	if _modified_stats.has(stat):
		return _stat_base_values[stat] + _modified_stats[stat]
	return _stat_base_values.get(stat, 0)

# 注册属性更新回调
func register_update_callback(stat: String, callback: Callable) -> void:
	if not _stat_update_callbacks.has(stat):
		_stat_update_callbacks[stat] = []
	
	if not _stat_update_callbacks[stat].has(callback):
		_stat_update_callbacks[stat].append(callback)

# 属性更新逻辑
func _update_stat(stat: String) -> void:

	
	# 计算基础值（不包含修改器）
	var base_value = _stat_base_values.get(stat, 0)
	var final_value = base_value
	var percentage_bonus = 0.0
	
	# 应用所有修改器
	for modifier in _stat_modifiers[stat].values():
		if modifier["type"] == "flat":
			final_value += modifier["value"]
		elif modifier["type"] == "percentage":
			percentage_bonus += modifier["value"]
	
	# 应用百分比加成
	final_value = final_value * (1 + percentage_bonus)
	
	# 计算并存储修正值
	_modified_stats[stat] = final_value - base_value
	#
	## 触发所有注册的回调
	#if _stat_update_callbacks.has(stat):
		#for callback in _stat_update_callbacks[stat]:
			#callback.call(stat, final_value)
