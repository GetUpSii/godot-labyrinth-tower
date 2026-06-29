class_name SkillSystem
var base: Dictionary = {}
# 库存名称
var user_name: String = ""
var base_size: int = 10

func get_skills() -> Array:
	return base.values()



func get_data() -> Dictionary:
	var data: Dictionary = {}
	data.set("user_name", user_name)
	data.set("base_size", base_size)
	data.set("base", [])
	for key in base:
		var skill_data:Dictionary = base[key].get_data()
		data["base"].append(skill_data)
	return data

func set_data(data: Dictionary) -> void:
	base.clear()
	base_size = data.get("base_size", 10)
	user_name = data.get("user_name", "勇士")
	var skill_array: Array = data.get("base", [])
	for skill_data in skill_array:
		var skill: SkillInstance =	SkillLoader.load_instance_from_data(skill_data)
		add_skill(skill)



func add_skill(skill: SkillInstance) -> bool:
	if skill == null:
		push_error("add skill null")
		return false
	var text: String
	if base.size() >= base_size:
		text = tr("log_skill_full") % base_size
		print(text)
		LogManager.add_entry(text, user_name)
		return false
	
	var template_id: String = skill.get_template_id()
	base.set(template_id, skill)
	return true
