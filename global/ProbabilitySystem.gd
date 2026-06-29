class_name ProbabilitySystem
# ========== 核心功能 ==========
# 权重概率选择器 (适合奖励池/技能触发等)
static func weighted_selection(items: Array[Dictionary]) -> Variant:
	var total_weight: float = 0.0
	for item in items:
		assert("weight" in item, "权重项缺少 'weight' 字段!")
		total_weight += item.weight
	
	var rand_val = randf_range(0, total_weight)
	var cumulative: float = 0.0
	
	for item in items:
		cumulative += item.weight
		if rand_val <= cumulative:
			return item.value if "value" in item else item
	return null

# 独立概率检查器 (适合暴击/闪避等)
static func check_probability(percent: float) -> bool:
	assert(percent >= 0 and percent <= 1, "概率值必须在0-1范围内")
	return randf() < percent

# ========== 调试工具 ==========
# 概率分布测试 (万次验证)
static func test_distribution(items: Array[Dictionary], trials: int = 10000) -> Dictionary:
	var results = {}
	# 初始化统计字典
	for item in items:
		var key = item.get("id", item.get("name", str(item)))
		results[key] = 0
	
	# 执行概率测试
	for i in range(trials):
		var selected = weighted_selection(items)
		var key = selected.get("id", selected.get("name", str(selected)))
		results[key] += 1
	
	# 计算实际概率
	for key in results:
		results[key] = float(results[key]) / trials * 100.0
	return results
