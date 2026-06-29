extends Node
static var _template_paths = {
	"craft": "res://data/craft/craft_template.json",
	##"default":"res://data/characters/enemy_templates.json",

}
static func set_template_path(category: String, path: String) -> void:
	_template_paths[category] = path

static func get_template_path(category: String) -> String:
	return _template_paths.get(category, _template_paths["default"])



static  func load_template_file(file_path: String) -> Dictionary:
	var data: Dictionary = {}
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		data = JSON.parse_string(content)
		file.close()
	return data



# 加载模板文件
static func load_static_templates() -> Array:
	var templates = []
	for key in _template_paths:
		var path: String = _template_paths[key]
		var data = load_template_file(path)
		if not data or not data is Dictionary:
			push_error("无效的路径")
			return []			
		for type in data:
			var arr = data[type]
			for entry in arr:
				var template: CraftTemplate = CraftTemplate.new()
				_apply_template_data(template, entry)
				templates.append(template)
	return templates

# 从数据字典加载实例
static func load_instance_from_data(data: Dictionary) -> CraftInstance:
	var template_id = data.get("template_id")
	if not template_id:
		push_error("缺少模板ID")
		return null
		
	# 通过工厂创建角色
	var instance = CraftFactory.create_craft(template_id)
	if not instance:
		push_error("无法创建合成实例: " + template_id)
		return null
	
	_apply_instance_data(instance, data)
	return instance

# 解析模板数据
static func _apply_template_data(template: CraftTemplate ,data: Dictionary) -> void:
	template.set_data(data)
	
# 解析模板数据
static func _apply_instance_data(instance: CraftInstance ,data: Dictionary) -> void:
	# 应用实例数据
	instance.set_data(data)
