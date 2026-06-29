extends Node
#class_name CharacterLoader	##单例自动加载
static var _template_paths = {
	"player": "res://data/character/player_templates.json",
	##"default":"res://data/characters/enemy_templates.json",
	"enemy": "res://data/character/enemy_templates.json"
}

## 在加载器中添加版本转换器
#static func migrate_v1_to_v2(data):
	## 将旧版完整数据转换为引用格式
	#if data.has("base_hp"):  # 检测旧版数据
		#return {
			#"template_id": data["id"],
			#"current_hp": data["current_hp"],
			## ...其他转换
		#}
	#return data

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
		print(data)			
		for type in data:
			var arr = data[type]
			for entry in arr:
				var template: CharacterTemplate = CharacterTemplate.new()
				_apply_template_data(template, entry)
				templates.append(template)
	return templates




# 保存模板
# CharacterLoader 中的 save_instance 方法
static func save_instance(instance: CharacterInstance, path: String) -> bool:
	if not instance:
		push_error("实例为空")
		return false

	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("文件写入失败: " + path)
		return false
	var data: Dictionary
	data.set("template_id", instance.template.id)
	# 只保存差异数据


	file.store_string(JSON.stringify(data))
	file.close()
	return true





# 从数据字典加载实例
static func load_instance_from_data(data: Dictionary) -> CharacterInstance:
	var template_id = data.get("template_id")
	if not template_id:
		push_error("缺少模板ID")
		return null
		
	# 通过工厂创建角色
	var instance = CharacterFactory.create_character(template_id)
	if not instance:
		push_error("无法创建角色实例: " + template_id)
		return null
	
	# 应用实例数据
	instance.set_data(data)
	
	# 应用修改属性
	if data.has("modified_stats"):
		for stat in data["modified_stats"]:
			if instance.modified_stats.has(stat):
				instance.modified_stats[stat] = data["modified_stats"][stat]
	
	# 验证数据
	instance.current_hp = min(instance.current_hp, instance.calculate_max_hp())
	instance.current_mp = min(instance.current_mp, instance.calculate_max_mp())
	
	return instance

## 加载json的基础数据到模板中
static func _apply_template_data(template: CharacterTemplate, data: Dictionary) -> void:
	template.set_data(data)
#	template.sprite_texture = data.get("sprite_texture")


##	应用实例数据
static func _apply_instance_data(instance: CharacterInstance, data: Dictionary) -> void:
	# 3. 应用实例特有数据
	instance.set_data(data)
	# 合并修改属性
	if data.has("modified_stats"):
		for stat in data["modified_stats"]:
			if instance.modified_stats.has(stat):
				instance.modified_stats[stat] = data["modified_stats"][stat]

	# 验证数据
	instance.current_hp = min(instance.current_hp, instance.calculate_max_hp())
	instance.current_mp = min(instance.current_mp, instance.calculate_max_mp())
