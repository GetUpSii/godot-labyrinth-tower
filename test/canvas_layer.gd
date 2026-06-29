extends Node2D








func _process(delta: float) -> void:
	queue_redraw()  # 请求重绘
	
func _draw() -> void:
	var paths = get_parent().paths
	if paths.size() < 2:
		return
		
	# 1. 绘制路径连线（蓝色线）
	for i in range(paths.size() - 1):
		draw_line(paths[i], paths[i+1], Color.ROYAL_BLUE, 2.0, true)
	
	# 2. 绘制路径节点（红色圆点）
	for point in paths:
		draw_circle(point, 4.0, Color.CRIMSON)
	
	# 3. 标记起点终点
	draw_circle(paths[0], 6.0, Color.FOREST_GREEN)  # 起点
	draw_circle(paths[-1], 6.0, Color.ORANGE)       # 终点
