class_name CraftTemplate

#enum CraftType {
#}

# 基础属性
var id: String                     # 唯一ID
var display_name: String           # 显示名称
#var type: int = ItemType.MATERIAL  # 道具类型
var icon: Texture                  # 图标
var description: String            # 描述
var price: int = 0
var recipe: Dictionary = {}
var reslut: String
var tool: String
## 扩展
#var trait_ids: Array = []          # 关联的词条ID列表

var effects: Array = []
# 检查是否为消耗品
## 载入数据
var _data: Dictionary = {}

func set_data(data: Dictionary) -> void:
	_data = data
	id = data.get("id")
	_update_localized()
	price = data.get("price", 0)
	recipe = data.get("recipe")
	tool = data.get("tool")
	reslut = data.get("result")

func update_display_name() -> void:
	_update_localized()

func _update_localized() -> void:
	var lang: String = Global.language
	display_name = _data.get("display_name_localized", {}).get(lang, "unnamed_item")
	description = _data.get("description_localized", {}).get(lang, _data.get("description", ""))
	
