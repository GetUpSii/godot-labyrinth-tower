extends Node
class_name LootPool

# 预定义的奖励池字典
static var loot_pools = {
	"common": {
		"red_herb": 0.3,
		"blue_herb": 0.2,
		"": 0.5,
	},
	"rare": {
		#"steel_shield": 0.08,
		"": 0.1,
		"red_herb": 0.5,
		"blue_herb": 0.4,
	},
	"advance": {
		"steel_shield": 0.05,
		"": 0.35,
		"red_herb": 0.2,
		"blue_herb": 0.1,
		"sword": 0.2,
		"ruby_ring": 0.1,
	},
	
}

# 核心随机获取函数，基于权重掉落
static func get_random_item(pool_name: String) -> String:
	var target_pool = loot_pools.get(pool_name, {})
	
	if target_pool.is_empty():
		push_warning("未找到奖励池: " + pool_name)
		return ""
	
	# 计算总权重
	var total_weight: float = 0.0
	for item in target_pool:
		var weight = target_pool[item]
		if weight > 0:
			total_weight += weight
	
	# 如果总权重为0，则没有可掉落的物品
	if total_weight <= 0:
		return ""
	
	# 生成随机数
	var random_value = randf() * total_weight
	var current_sum: float = 0.0
	
	# 根据权重选择物品
	for item in target_pool:
		var weight = target_pool[item]
		if weight > 0:
			current_sum += weight
			if random_value <= current_sum:
				return item
	
	# 如果没有匹配到（理论上不应该发生，除非权重都是0）
	return ""


static func get_loot(pool_name: String) -> ItemInstance:
	var item_id = get_random_item(pool_name)
	if item_id == "":
		return null  # 表示没有获得任何物品
	var item: ItemInstance = ItemFactory.create_item(item_id)
	return item
