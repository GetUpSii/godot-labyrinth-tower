class_name SkillFactory

# 预加载的模板字典
static var _templates: Dictionary = {}

# 初始化工厂
static func initialize():
	# 加载所有模板文件
	var templates = SkillLoader.load_static_templates()
	for template in templates:
		register_template(template)
	print(_templates)


## 创建技能实例
static func create_skill(template_id: String) -> SkillInstance:
	if not _templates.has(template_id):
		push_error("无法创建技能实例: 未知ID - " + template_id)
		return null
		## 尝试动态加载
		#var template = ItemLoader.load_template_by_id(template_id)
		#if template:
			#_templates[template_id] = template
		#else:
			#push_error("无法创建道具实例: 未知ID - " + template_id)
			#return null
	var skill: SkillInstance = SkillInstance.new(_templates[template_id])
	return skill


# 检查模板是否存在
static func _template_exists(template_id: String) -> bool:
	return _templates.has(template_id)

# 手动注册模板 (用于动态创建的角色)
static func register_template(_template: SkillTemplate) -> void:
	assert(_template.id != "", "Template must have valid ID")
	_templates[_template.id] = _template

# 获取模板数据
static func get_template(template_id: String) -> SkillInstance:
	return _templates.get(template_id)
