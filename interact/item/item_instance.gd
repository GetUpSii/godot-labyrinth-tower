class_name ItemInstance

## 基础属性
var template: ItemTemplate   # 关联的模板
var unique_id: String        # 实例唯一ID
var quantity: int = 1        # 数量（可堆叠物品）
var traits: Array = []       # 关联的词条实例

#var executor = EffectExecutor.new()
## 装备
var is_equipped: bool = false
func is_consumable() -> bool:
	return template.type == template.ItemType.CONSUMABLE

# 检查是否为装备
func is_equipment() -> bool:
	return template.type == template.ItemType.EQUIPMENT

## 返回显示的名字
func get_display_name() -> String:
	return template.display_name

## 返回物品的模板id
func get_template_id() -> String:
	return template.id

## 返回物品的描述
func get_description() -> String:
	return template.description

func get_max_stack() -> int:
	return template.max_stack

func get_price() -> int:
	return template.price

func get_type():
	return template.type


func get_slot() -> String:
	return template.slot

func _init(p_template: ItemTemplate):
	template = p_template
	unique_id = generate_unique_id()
	debug_print()


# 生成唯一ID
static func generate_unique_id() -> String:
	return "item_%s_%d" % [str(randi() % 10000).pad_zeros(4), Time.get_ticks_msec()]

# 是否可堆叠
func is_stackable() -> bool:
	return template.max_stack > 1

# 尝试合并堆叠（相同模板且可堆叠）
func try_merge(other: ItemInstance) -> bool:
	if template.id != other.template.id:
		return false
	if not is_stackable():
		return false
	
	var total = quantity + other.quantity
	if total <= template.max_stack:
		quantity = total
		return true
	return false


func get_data() -> Dictionary:
	var data: Dictionary = {}
	data.set("template_id", get_template_id())
	data.set("unique_id", unique_id)
	data.set("quantity", quantity)
	data.set("is_equipped", is_equipped)
	return data

func set_data(data: Dictionary) -> void:
	unique_id = data.get("unique_id", "")
	quantity = data.get("quantity", 0)
	is_equipped = data.get("is_equipped", false)



func use(way: String, user: CharacterInstance = null) -> bool:
	match way:
		"consume": return consume(user)
		"equip": return equip(user)
		"unequip": return unequip(user)
		_: 
			push_error("can not find this way to use")
			return false

# 使用道具
func consume(user: CharacterInstance = null) -> bool:
	if not is_consumable() :
		push_warning("非消耗品不可使用")
		return false
	if not template.target == "player":
		LogManager.add_entry(tr("log_cannot_use_on") + template.target)
		return false
	# 应用直接效果
	for effect: EffectDescriptor in template.effects:
		effect.params.set("unique_id","consume" + unique_id + generate_unique_id())
		
	EffectExecutor.apply_effects(template.effects, user)
	
	# 应用词条效果
	##apply_traits(user)
	# 减少数量
	quantity -= 1
	return true


## 装备
func equip(user: CharacterInstance) -> bool:
	if not is_equipment():
		push_warning("非装备类物品无法装备")
		return false
	if user.handle_equipped(get_slot(), self.unique_id):
		pass
	else:
		equip(user)
	
	# 应用装备效果
	for effect: EffectDescriptor in template.effects:
		effect.params.set("unique_id", "equip" + unique_id + effect.type)
	EffectExecutor.apply_effects(template.effects, user)
	##apply_traits(character)	##词条，还没完成
	
	is_equipped = true
	return true
	
## 卸下
func unequip(user: CharacterInstance) -> bool:
	if template.type != ItemTemplate.ItemType.EQUIPMENT:
		push_warning("非装备类物品无法装备")
		return	false
	if !is_equipped: return false
	user.unequip_on_slot(get_slot())
	# 移除装备效果
	# 移除所有装备效果
	EffectExecutor.unapply_effects(template.effects, user)
	is_equipped = false
	return true





# 应用词条到目标
func apply_traits(target: Object) -> void:
	for tra in traits:
		tra.apply_to(target)

# 移除词条效果
func remove_traits(target: Object) -> void:
	for tra in traits:
		tra.remove_from(target)


func debug_print() -> void:
	print("create unique id: %s, display name: %s," % [unique_id, template.display_name])
