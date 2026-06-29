class_name CraftSystem
# 库存 [unique_id: ItemInstance]
var base: Dictionary
# 库存名称
var user_name: String = ""
# 库存大小
var base_size: int = 99
signal on_craft_ui_update
func get_data() -> Dictionary:
	var data: Dictionary = {}
	data.set("base", [])
	for key in base:
		var craft_data: Dictionary = base[key].get_data()
		data["base"].append(craft_data)
	data.set("base_size", base_size)
	data.set("user_name", user_name)
	
	return data

func set_data(data: Dictionary) -> void:
	base.clear()
	base_size = data.get("base_size", 10)
	user_name = data.get("user_name", "勇士")
	var crafts: Array = data.get("base", [])
	for craft_data in crafts:
		var craft_instance: CraftInstance =	 CraftLoader.load_instance_from_data(craft_data)
		add_craft(craft_instance)

func add_craft(_craft: CraftInstance) -> void:
	## 如果配方的模板名称已经存在将不再会获得配方
	if _craft:
		base.set(_craft.get_template_id(), _craft)



## 合成
func craft(inventroy: InventorySyetem, _type: String, _tool: String) -> bool:
	## 1.检查配方是否存在
	if !base.has(_type):
		LogManager.add_entry(tr("craft_recipe_not_found"))
		return false
	
	var craft_instance: CraftInstance = base.get(_type)
	if !craft_instance.get_tool() == _tool:
		LogManager.add_entry(tr("craft_missing_tool"))
		return false
	
	var recipe: Dictionary = craft_instance.get_recipe()
	var missing_materials = []
	## 2.检查材料是否足够
	for material_id in recipe.keys():
		var required_amount: int = recipe[material_id]
		var current_amount: int = inventroy.get_item_quantity(material_id)
		if current_amount < required_amount:
			missing_materials.append({
				"id": ItemFactory.get_template_display_name(material_id),
				"required": required_amount,
				"current": current_amount
			})
	## 3. 如果有缺失材料，返回错误
	if missing_materials.size() > 0:
		#LogManager.add_entry("材料不足，无法制作 %s" % potion_type)
		for material in missing_materials:
			LogManager.add_entry(tr("craft_missing_material") % [
				material["id"], material["required"], material["current"]]) 
		return false
	
	## 4. 扣除材料
	for material_id in recipe.keys():
		var required_amount = recipe[material_id]
		remove_materials(inventroy, material_id, required_amount)
	
	# 5. 创建药水并添加到背包
	var item: ItemInstance = create_item(_type)
	if not item:
		push_error("找不到物品模板: " + _type)
		return false
	
	inventroy.add_item(item)

	print("成功制作了 %s!" % item.get_display_name())
	return true


#
func create_item(_type: String) -> ItemInstance:
	var item: ItemInstance = ItemFactory.create_item(_type)
	return item 
#
#
#
## 获取玩家背包中指定材料的数量
func get_material_count(inventory: InventorySyetem, material_id: String) -> int:
	var count = 0
	for item: ItemInstance in inventory.get_items():
		if item.get_template_id() == material_id:
			count += item.quantity
	return count

## 从背包中移除指定数量的材料
func remove_materials(inventory: InventorySyetem, material_id: String, amount: int) -> void:
	var remaining = amount
	# 收集所有匹配的物品（按数量从少到多排序）
	var matched_items = []
	var items = inventory.get_items()
	for item: ItemInstance in items:
		if item.get_template_id() == material_id:
			matched_items.append(item)
	
	# 按数量排序（优先消耗数量少的物品）
	matched_items.sort_custom(func(a, b): return a.quantity < b.quantity)
	
	# 从背包中移除材料
	var items_to_remove = []
	
	for item: ItemInstance in matched_items:
		if item.quantity <= remaining:
			# 整个物品都被消耗
			remaining -= item.quantity
			items_to_remove.append(item.get_template_id())
		else:
			# 部分消耗
			item.quantity -= remaining
			remaining = 0
			break
	
	# 移除完全消耗的物品
	for template_id in items_to_remove:
		inventory.remove_item_by_id(template_id)
	
	# 如果还有剩余材料需要移除但背包中没有足够的物品
	if remaining > 0:
		push_error("材料移除异常: 需要移除 %d 个 %s, 但只移除了 %d 个" % [
			amount, material_id, amount - remaining
		])
