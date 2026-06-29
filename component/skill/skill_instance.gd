class_name SkillInstance


## 基础属性
var template: SkillTemplate   # 关联的模板
var unique_id: String        # 实例唯一ID
var traits: Array = []       # 关联的词条实例
var can_release: bool = true
var level: int = 1
#var executor = EffectExecutor.new()

signal on_skill_cooldown

## 返回显示的名字
func get_display_name() -> String:
	return template.display_name

## 返回物品的模板id
func get_template_id() -> String:
	return template.id

## 返回物品的描述
func get_description() -> String:
	return template.description

func get_cooldown() -> float:
	return template.cooldown


func get_mana() -> int:
	return template.mana

func _init(p_template: SkillTemplate):
	template = p_template
	unique_id = generate_unique_id()
	debug_print()


# 生成唯一ID
static func generate_unique_id() -> String:
	return "item_%s_%d" % [str(randi() % 10000).pad_zeros(4), Time.get_ticks_msec()]


func get_data() -> Dictionary:
	var data: Dictionary = {}
	data.set("template_id", get_template_id())
	data.set("level", level)
	return data


func set_data(data: Dictionary) -> void:
	level = data.get("level")

## 一个技能不止一个效果，这里要补充技能效果的目标可能是对自己
func trigger(_owner:CharacterInstance ,target: CharacterInstance) -> void:
	for effect: EffectDescriptor in template.effects:
		effect.params.set("unique_id", "skill" + unique_id)
		if effect.target == "owner":
			EffectExecutor.apply_single_effect(effect, _owner)
		elif effect.target == "target":
			EffectExecutor.apply_single_effect(effect, target)
		elif effect.target == "both":
			EffectExecutor.apply_single_effect(effect, target, _owner)
	#EffectExecutor.apply_effects(template.effects, target)

## 使用的
func set_cooldown(_v: bool) -> void:
	can_release = _v
	on_skill_cooldown.emit(_v)

## 技能有释放失败的可能吗？因为关系到法力值和冷却值


	##apply_traits(character)	##词条，还没完成

## 装备

## 卸下



func debug_print() -> void:
	print("create unique id: %s, display name: %s," % [unique_id, template.display_name])
