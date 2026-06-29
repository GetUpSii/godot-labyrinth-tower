class_name ItemTemplate
enum ItemType {
	CONSUMABLE,  # 消耗品
	EQUIPMENT,    # 装备
	MATERIAL,     # 材料
	KEY_ITEM,      # 关键物品
}

# 基础属性
var id: String                     # 唯一ID
var display_name: String           # 显示名称
var type: int = ItemType.MATERIAL  # 道具类型
var max_stack: int = 1             # 最大堆叠数
var icon: Texture                  # 图标
var description: String            # 描述
var target: String
var price: int = 0
## 扩展
var trait_ids: Array = []          # 关联的词条ID列表

var effects: Array = []
# 检查是否为消耗品
## 装备
var slot: String


## 载入数据
var _data: Dictionary = {}  # 保存原始数据，用于语言切换时刷新

func set_data(data: Dictionary) -> void:
	_data = data
	var item_type = _str_to_item_type(data.get("type", "MATERIAL"))
	id = data.get("id")
	_update_localized()
	type = item_type
	max_stack = data.get("max_stack", 1)
	target = data.get("target", "")
	price = data.get("price", 0)
	slot = data.get("slot", "")
	
	# 效果解析（添加类型转换）
	if data.has("effects"):
		var effect_dict = data["effects"]
		for effect in effect_dict:
			effects.append(EffectDescriptor.create_from_config(effect))
	# 解析词条ID
	if data.has("traits"):
		trait_ids = data["traits"]

## 根据当前语言刷新显示名称和描述
func update_display_name() -> void:
	_update_localized()

func _update_localized() -> void:
	var lang: String = Global.language
	display_name = _data.get("display_name_localized", {}).get(lang, "unnamed_item")
	description = _data.get("description_localized", {}).get(lang, _data.get("description", ""))



# 是否有词条
func has_traits() -> bool:
	return trait_ids.size() > 0

# 字符串转枚举（静态方法）
static func _str_to_item_type(type_str: String) -> int:
	match type_str.to_upper():
		"CONSUMABLE": return ItemType.CONSUMABLE
		"EQUIPMENT": return ItemType.EQUIPMENT
		"MATERIAL": return ItemType.MATERIAL
		"KEY_ITEM": return ItemType.KEY_ITEM
	push_error("未知道具类型: " + type_str)
	return ItemType.MATERIAL
