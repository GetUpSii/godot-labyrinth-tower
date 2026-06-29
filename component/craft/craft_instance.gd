class_name CraftInstance

## 基础属性
var template: CraftTemplate   # 关联的模板
var unique_id: String        # 实例唯一ID
#var executor = EffectExecutor.new()
## 返回显示的名字
func get_display_name() -> String:
	return template.display_name

## 返回物品的模板id
func get_template_id() -> String:
	return template.id

## 返回物品的描述
func get_description() -> String:
	return template.description

func get_tool() -> String:
	return template.tool

func get_result() -> String:
	return template.reslut


func get_recipe() -> Dictionary:
	return template.recipe

func get_price() -> int:
	return template.price


func _init(_template: CraftTemplate):
	template = _template
	unique_id = generate_unique_id()
	#debug_print()


# 生成唯一ID
static func generate_unique_id() -> String:
	return "craft_%s_%d" % [str(randi() % 10000).pad_zeros(4), Time.get_ticks_msec()]

# 是否可堆叠
func is_stackable() -> bool:
	return template.max_stack > 1


func get_data() -> Dictionary:
	var data: Dictionary = {}
	data.set("template_id", get_template_id())
	data.set("unique_id", unique_id)

	return data

func set_data(data: Dictionary) -> void:
	unique_id = data.get("unique_id", "")


#
#func use(way: String, user: CharacterInstance = null) -> bool:
	#match way:
		#"consume": return consume(user)
		#"equip": return equip(user)
		#"unequip": return unequip(user)
		#_: 
			#push_error("can not find this way to use")
			#return false
