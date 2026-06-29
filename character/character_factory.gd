class_name CharacterFactory

# 模板缓存 {id: CharacterTemplate}
static var _templates: Dictionary = {}

# 模板地址
## 核心初始化方法（游戏启动时调用）
static func initialize() -> void:
	# 加载所有模板文件
	var templates = CharacterLoader.load_static_templates()
	for template in templates:
		register_template(template)

	##print(_templates)
# 检查模板是否存在，好像有点小问题别用
static func _template_exists(template_id: String) -> bool:
	return _templates.has(template_id)

# 手动注册模板 (用于动态创建的角色)
static func register_template(template: CharacterTemplate) -> void:
	assert(template.id != "", "Template must have valid ID")
	_templates[template.id] = template

# 获取模板数据
static func get_template(template_id: String) -> CharacterTemplate:
	return _templates.get(template_id)

# 创建角色实例 (主入口)
static func create_character(template_id: String) -> CharacterInstance:
	###如果没有，就需要动态创建
	if not _template_exists(template_id):
		push_error("Cannot create character: Template %s not found" % template_id)
		#if not _load_template(template_id):
			#push_error("Cannot create character: Template %s not found" % template_id)
			#return null
	return CharacterInstance.new(_templates[template_id])
