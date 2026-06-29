#extends Resource
class_name CharacterTemplate

# 定义资质枚举
enum Quality {
	PRIMARY,    # 初级
	INTERMEDIATE, # 中级
	ADVANCED,   # 高级
	SPECIAL     # 特级
}

# 模板属性
var id: String                     # 唯一标识符
var display_name: String           # 显示名称
var quality: Quality               # 资质等级
var base_hp: int                   # 基础HP
var base_mp: int                   # 基础MP
var base_attack: int               # 基础攻击力
var base_defense: int              # 基础防御力
var growth_rate: float = 1.0       # 成长系数
var sprite_texture: Texture        # 精灵纹理
var animations: Dictionary        # 动画资源
var description: String = ""      # 描述
var _data: Dictionary = {}        # 原始数据，用于语言切换


## 通过外部文件导入初始值
## 保留 _init() 用于数据验证
#func _init():
	#assert(base_hp > 0 && base_mp > 0, "HP和MP必须为正数")
	#assert(base_attack >= 0, "攻击力不能为负")
	#assert(quality in [PRIMARY, INTERMEDIATE, ADVANCED, SPECIAL], "无效资质等级")	
# 字符串转枚举（静态方法方便外部调用）

func set_data(data: Dictionary) -> void:
	_data = data
	id = data.get("id")
	_update_localized()
	quality = _str_to_quality(data.get("quality", "PRIMARY"))
	base_hp = data.get("base_hp", 1)
	base_mp = data.get("base_mp", 1)
	base_attack = data.get("base_attack", 0)
	base_defense = data.get("base_defense", 0)
	growth_rate = data.get("growth_rate", 0.0)

func update_display_name() -> void:
	_update_localized()

func _update_localized() -> void:
	var lang: String = Global.language
	display_name = _data.get("display_name_localized", {}).get(lang, "unnamed_item")
	description = _data.get("description_localized", {}).get(lang, _data.get("description", ""))
	





static func _str_to_quality(quality_str: String) -> Quality:
	match quality_str.to_upper():
		"PRIMARY":     return Quality.PRIMARY
		"INTERMEDIATE":return Quality.INTERMEDIATE
		"ADVANCED":   return Quality.ADVANCED
		"SPECIAL":    return Quality.SPECIAL
	push_error("未知资质类型: " + quality_str)
	return Quality.PRIMARY

# 枚举转字符串（用于序列化）
static func _quality_to_str(_quality: int) -> String:
	match _quality:
		Quality.PRIMARY:     return "PRIMARY"
		Quality.INTERMEDIATE:return "INTERMEDIATE"
		Quality.ADVANCED:   return "ADVANCED"
		Quality.SPECIAL:    return "SPECIAL"
	push_error("无效资质枚举值: " + str(_quality))
	return "PRIMARY"
