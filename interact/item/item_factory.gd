class_name ItemFactory

# 预加载的模板字典
static var _templates: Dictionary = {}

# 初始化工厂
static func initialize():
	# 加载所有模板文件
	var templates = ItemLoader.load_static_templates()
	for template in templates:
		register_template(template)
	print(_templates)

static func get_template_display_name(template_id: String) -> String:
	if _templates.has(template_id):
		return _templates.get(template_id).display_name
	return ""


# 创建道具实例
static func create_item(template_id: String, _quantity: int = 1) -> ItemInstance:
	if not _templates.has(template_id):
		push_error("无法创建道具实例: 未知ID - " + template_id)
		return null
		## 尝试动态加载
		#var template = ItemLoader.load_template_by_id(template_id)
		#if template:
			#_templates[template_id] = template
		#else:
			#push_error("无法创建道具实例: 未知ID - " + template_id)
			#return null
	var item: ItemInstance = ItemInstance.new(_templates[template_id])
	item.quantity = _quantity
	return item


# 检查模板是否存在
static func _template_exists(template_id: String) -> bool:
	return _templates.has(template_id)

# 手动注册模板 (用于动态创建的角色)
static func register_template(template: ItemTemplate) -> void:
	assert(template.id != "", "Template must have valid ID")
	_templates[template.id] = template

# 获取模板数据
static func get_template(template_id: String) -> ItemTemplate:
	return _templates.get(template_id)
