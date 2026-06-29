class_name SkillTemplate

#enum ItemType {
	#CONSUMABLE,  # 消耗品
	#EQUIPMENT,    # 装备
	#MATERIAL,     # 材料
	#KEY_ITEM,      # 关键物品
#}

# 基础属性
var id: String                     # 唯一ID
var display_name: String           # 显示名称
var cooldown: float					#冷却时间
var mana: int					#消耗法力
var range: float						#施法范围
var icon: Texture                  # 图标
var description: String            # 描述
var target: String

## 扩展
var trait_ids: Array = []          # 关联的词条ID列表

var effects: Array = []



## 载入数据
var _data: Dictionary = {}

func set_data(data: Dictionary) -> void:
	_data = data
	id = data.get("id")
	_update_localized()
	cooldown = data.get("cooldown", 0.0)
	mana = data.get("mana", -1)
	range = data.get("range", 0.0)
	target = data.get("target", "")

	# 效果解析（添加类型转换）
	if data.has("effects"):
		var effect_dict = data["effects"]
		
		for effect in effect_dict:
			effect.set("target", target)
			effects.append(EffectDescriptor.create_from_config(effect))

func update_display_name() -> void:
	_update_localized()

func _update_localized() -> void:
	var lang: String = Global.language
	display_name = _data.get("display_name_localized", {}).get(lang, "unnamed_item")
	description = _data.get("description_localized", {}).get(lang, _data.get("description", ""))
	# 解析词条ID
	#if data.has("traits"):
		#trait_ids = data["traits"]
