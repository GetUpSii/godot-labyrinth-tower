class_name EffectDescriptor

var type: String             # 效果类型（instant_heal/status等）
var params: Dictionary       # 效果参数
var target: String

# 从配置数据创建
static func create_from_config(config: Dictionary) -> EffectDescriptor:
	var desc = EffectDescriptor.new()
	desc.type = config.get("type", "")
	desc.target = config.get("target", "")
	desc.params = config.duplicate()
	desc.params.erase("type")  # 移除类型字段，剩余为参数
	return desc
