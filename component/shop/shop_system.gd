class_name ShopSystem

const PROFITEER_MULTIPLIER := 1.4  # 出售价格加价40%
const LOWBALL_MULTIPLIER := 0.6    # 收购价格压价40%

## 狡猾商人收购价格（玩家卖出物品）
func calculate_sell_price(base_cost: int) -> int:
	# 狡猾商人会刻意压价，只支付基础价的60%
	return int(base_cost * LOWBALL_MULTIPLIER)

## 狡猾商人出售价格（玩家购买装备）
func calculate_buy_price(base_cost: int) -> int:
	# 狡猾商人会大幅加价，按基础价的140%出售
	return int(base_cost * PROFITEER_MULTIPLIER)

## 获取奸商系数说明（用于UI显示）
func get_profiteer_tip() -> String:
	return "⚠️ 狡猾商人策略：\n- 出售价格 +%.0f%%\n- 收购价格 -%.0f%%" % [
		(PROFITEER_MULTIPLIER - 1) * 100,
		(1 - LOWBALL_MULTIPLIER) * 100
	]
