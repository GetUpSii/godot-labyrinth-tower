class_name InventorySyetem

# 库存 [unique_id: ItemInstance]
var base: Dictionary = {}
# 库存名称
var user_name: String = ""
# 库存大小
var base_size: int = 99
# 库存金币
var gold: int = 0
signal on_inventory_update

func _init(_p_name: String) -> void:
	user_name = _p_name

func get_data() -> Dictionary:
	var data: Dictionary = {}
	data.set("base", [])
	for key in base:
		var item_data: Dictionary = base[key].get_data()
		data["base"].append(item_data)
	data.set("base_size", base_size)
	data.set("gold", gold)
	data.set("user_name", user_name)
	
	return data

func set_data(data: Dictionary) -> void:
	base.clear()
	base_size = data.get("base_size", 10)
	gold = data.get("gold", 0)
	user_name = data.get("user_name", "勇士")
	var items: Array = data.get("base", [])
	for item_data in items:
		var item: ItemInstance =	 ItemLoader.load_instance_from_data(item_data)
		add_item(item)

## 添加物品到库存
## 一种情况，背包没有容量了
## 第二种情况，已经有相同的物品存在了，这个时候进行合并
func add_item(item: ItemInstance) -> bool:
	if item == null:
		push_error("add item null")
		return false
	
	#if item.get_max_stack() > 
	
	var text: String
	if base.size() >= base_size:
		text = tr("ui_inventory_full") % base_size
		print(text)
		LogManager.add_entry(text, user_name)
		return false
	
	var template_id: String = item.get_template_id()
	## 如果是同一种模板的物品，就重叠起来（消耗品）
	if base.has(template_id):
		## 合并
		var dict: ItemInstance = base.get(template_id, null)
		print("return dict " , dict)
		if dict.try_merge(item) and dict:
			text =tr("log_merge_item") % [item.get_display_name(), item.quantity]
			print(text)
			LogManager.add_entry(text, user_name)
			on_inventory_update.emit()
			return true
		else:
			if (base.size() + 1) > base_size:
				print("背包已满 ")
			
			return false
	base[template_id] = item

	text = tr("log_add_item") % item.get_display_name()
	LogManager.add_entry(text, user_name)
	on_inventory_update.emit()
	return true


func reduce_item(template_id: String, quantity: int) -> bool:
	if get_item_by_template(template_id).is_equipped:
		return false
	if get_item_quantity(template_id) < quantity:
		#remove_item_by_id(template_id)
		return false
	base[template_id].quantity -= quantity
	if base[template_id].quantity == 0:
		remove_item_by_id(template_id)
	on_inventory_update.emit()
	return true


# 从库存中移除物品
func remove_item(item: ItemInstance) -> bool:
	on_inventory_update.emit()
	return remove_item_by_id(item.get_template_id())

# 通过唯一ID移除物品
func remove_item_by_id(template_id: String) -> bool:
	if base.has(template_id):
		var item: ItemInstance = base[template_id]
		if item.is_equipment() and item.is_equipped:
			LogManager.add_entry(tr("log_cannot_remove_equipped"))
			return false
		base.erase(template_id)
		var text: String
		text = tr("log_remove_item") % [item.get_display_name()]
		print(text)
		LogManager.add_entry(text, user_name)
		on_inventory_update.emit()
		return true
	return false

func has_item(template_id: String) -> bool:
	var item: ItemInstance = base.find_key(template_id)
	if item == null:
		return false
	if item.get_template_id() == template_id:
		on_inventory_update.emit()
		return true
	return false

func get_item_quantity(template_id: String) -> int:
	if !base.has(template_id):
		return 0
	return base.get(template_id).quantity


## 通过模板（类型）获得物品
func get_item_by_template(template_id: String) -> ItemInstance:
	return base.get(template_id)

# 通过唯一ID获取物品
func get_item_by_id(unique_id: String) -> ItemInstance:
	for key in base:
		if base[key]["unique_id"] == unique_id:
			var item: ItemInstance = base.get(key)
			return	item
	return null
# 获取所有成员列表（按添加顺序）
func get_items() -> Array:
	return base.values()

func update_item(item: ItemInstance) -> void:
	if item.quantity == 0:
		on_inventory_update.emit()
		remove_item(item)


# 获取所有物品ID列表
func get_item_ids() -> Array:
	return base.keys()

func debug_log() -> void:
	print(base)
	
	
	pass
