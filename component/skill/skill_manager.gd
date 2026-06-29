## SkillManager.gd 核心管理类
#
#class_name SkillManager extends Node:
	#var skills: Dictionary = {} # 所有已注册的技能
	#
	#func _init():
		#load_skill_templates()
		#
	## 加载所有技能模板
	#func load_skill_templates():
		#for skill_template in ResourceLoader.get_resources_in_path("res://resource/skill/"):
			#if is_class(skill_template, "SkillTemplate"):
				#skills[skill_template.id] = SkillInstance.new(skill_template)
	#
	## 注册新技能的方法（用于导入或自定义）
	#func register_skill(skill_instance):
		#skills[skill_instance.unique_id] = skill_instance
		#
	## 获取所有可用技能
	#func get_available_skills(character) -> Array:
		#var result: Array = []
		#
		#for skill in skills.values():
			#if is_valid_for_character(skill, character):
				#if can_be_used(skill, character):
					#result.append(skill)
					#
		#return result
	#
	## 判断技能是否适用于角色的函数
	#func is_valid_for_character(skill_template_id, character) -> bool:
		#var template = load_skill_template(skill_template_id)
		#
		#match template.effect_type:
			#case "damage":
				#return true  // 所有伤害类技能都可用
				#
			#case "heal": 
				#if character.template.id == "player1":
					#return true
					#
			#case "buff": 
				#// 可能需要特定条件
