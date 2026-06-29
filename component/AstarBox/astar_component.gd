extends Node
class_name AstarComponent

## 高级A*导航组件
## 需要在使用时调用astar_init()
## 地图更新时调用astar_update()	2025.08.06

@onready var astar_node: AStar2D = AStar2D.new()
@export var MapNode: Node2D
@export var navigation_layer: TileMapLayer
@export var collision_layer: TileMapLayer
@export var offset: Vector2 = Vector2(8,8)
var map_rect: Rect2i
var map_origin: Vector2i
var map_size: Vector2i

var debug_line: Line2D = Line2D.new()

# 初始化A*导航
func astar_init() -> void:
	# 初始化调试线
	debug_line.width = 2.0
	debug_line.default_color = Color.RED
	add_child(debug_line)
	
	# 连接信号
	if SignalManager.has_signal("on_tilemap_astar_navigation"):
		SignalManager.on_tilemap_astar_navigation.connect(on_handle_astar_navigation)
	if SignalManager.has_signal("on_tilemap_astar_update_map"):
		SignalManager.on_tilemap_astar_update_map.connect(on_handle_astar_update)
	
	# 初始化地图数据
	update_map_data()
	on_handle_astar_update()

# 更新地图基础数据
func update_map_data() -> void:
	if navigation_layer:
		map_rect = navigation_layer.get_used_rect()
		map_origin = map_rect.position
		map_size = map_rect.size
	else:
		push_error("AstarComponent: navigation_layer not assigned!")
# 处理地图更新
func on_handle_astar_update() -> void:
	if not navigation_layer:
		push_error("AstarComponent: navigation_layer is null, cannot update A*")
		return
	
	# 清除旧数据
	astar_node.clear()
	# 更新地图数据
	update_map_data()
	# 重建A*节点
	create_astar_nodes()
	connect_astar_nodes()
	# 处理碰撞
	process_collisions()
	print("A*导航网格已更新，包含 ", astar_node.get_point_count(), " 个节点")

# 创建A*节点
func create_astar_nodes() -> void:
	if not navigation_layer:
		return
	
	# 获取导航层所有使用过的单元格
	var cells = navigation_layer.get_used_cells()
	for cell in cells:
		# 跳过无效单元格
		if is_outside_map_bounds(cell):
			continue
		# 获取导航数据
		var tile_data = navigation_layer.get_cell_tile_data(cell)
		if not tile_data:
			continue
		# 检查导航多边形
		var nav_polygon = tile_data.get_navigation_polygon(0)
		if not nav_polygon:
			continue
		# 添加点到A*
		var point_index = calculate_point_index(cell)
		if not astar_node.has_point(point_index):
			astar_node.add_point(point_index, Vector2(cell.x, cell.y))

# 连接A*节点
func connect_astar_nodes() -> void:
	for id in astar_node.get_point_ids():
		var cell_position = Vector2i(astar_node.get_point_position(id))
		
		# 四方向连接
		var directions = [
			Vector2i.RIGHT, Vector2i.LEFT, 
			Vector2i.DOWN, Vector2i.UP,
			# 可选：添加对角线方向
			# Vector2i(1, 1), Vector2i(-1, 1),
			# Vector2i(1, -1), Vector2i(-1, -1)
		]
		
		for dir in directions:
			var neighbor_cell = cell_position + dir
			var neighbor_index = calculate_point_index(neighbor_cell)
			
			if is_outside_map_bounds(neighbor_cell):
				continue
			
			if astar_node.has_point(neighbor_index):
				# 避免重复连接
				if not astar_node.are_points_connected(id, neighbor_index):
					astar_node.connect_points(id, neighbor_index, true)

# 处理碰撞
func process_collisions() -> void:
	if not collision_layer:
		return
	
	#  处理碰撞层的瓦片碰撞
	var collision_cells = collision_layer.get_used_cells()
	for cell in collision_cells:
		var tile_data = collision_layer.get_cell_tile_data(cell)
		if tile_data and tile_data.get_collision_polygons_count(0) > 0:
			var point_index = calculate_point_index(cell)
			if astar_node.has_point(point_index):
				astar_node.remove_point(point_index)
	
	# 处理动态碰撞体（在碰撞层上的子节点）
	for child in collision_layer.get_children():
		if child is CollisionShape2D:
			process_collision_object(child)

# 处理单个碰撞体
func process_collision_object(obj: CollisionShape2D) -> void:
	if not obj.visible:
		return
	
	# 获取碰撞体影响的单元格
	var affected_cells = get_collision_cells(obj)
	
	for cell in affected_cells:
		var point_index = calculate_point_index(cell)
		if astar_node.has_point(point_index):
			astar_node.remove_point(point_index)

# 获取碰撞体影响的单元格
func get_collision_cells(obj: CollisionShape2D) -> Array:
	var cells = []
	
	# 尝试获取形状
	var shape: Shape2D
	if obj is CollisionShape2D:
		shape = obj.shape
	elif obj is CollisionShape2D:
		# 简化处理：使用边界矩形
		var rect = obj.get_polygon().get_rect()
		shape = RectangleShape2D.new()
		shape.size = rect.size
	
	if shape:
		# 计算碰撞体在全局坐标中的位置
		var global_transform = obj.global_transform
		var global_position = global_transform.get_origin()
		var global_rect = Rect2(global_position - shape.get_rect().size / 2, shape.get_rect().size)
		
		# 将全局坐标转换为地图单元格
		var start_cell = navigation_layer.local_to_map(global_rect.position)
		var end_cell = navigation_layer.local_to_map(global_rect.end)
		
		for x in range(start_cell.x, end_cell.x + 1):
			for y in range(start_cell.y, end_cell.y + 1):
				cells.append(Vector2i(x, y))
	
	return cells

# 计算点索引
func calculate_point_index(cell: Vector2i) -> int:
	return cell.x + cell.y * map_size.x

# 检查是否超出地图边界
func is_outside_map_bounds(cell: Vector2i) -> bool:
	return cell.x < map_rect.position.x or cell.y < map_rect.position.y or \
		   cell.x >= map_rect.end.x or cell.y >= map_rect.end.y

# 处理导航请求
func on_handle_astar_navigation(id: int, start_pos: Vector2, end_pos: Vector2) -> void:
	if not navigation_layer:
		push_error("AstarComponent: navigation_layer not set for navigation")
		return
	
	var start_cell = navigation_layer.local_to_map(start_pos)
	var end_cell = navigation_layer.local_to_map(end_pos)
	
	# 检查起点和终点是否有效
	if is_outside_map_bounds(start_cell) or is_outside_map_bounds(end_cell):
		push_error("AstarComponent: Start or end position out of bounds")
		return
	
	var path = get_nav_path(start_cell, end_cell)
	
	if not Global.current_astar_path.has(id):
		Global.current_astar_path[id] = {}
	
	Global.current_astar_path[id] = path
	draw_path(path)
	print("navgation is ",path)
	if SignalManager.has_signal("on_tilemap_astart_get_path_completed"):
		SignalManager.on_tilemap_astart_get_path_completed.emit(id, path)

# 绘制路径 
func draw_path(path: PackedVector2Array) -> void:
	debug_line.clear_points()
	
	for point in path:
		# 将单元格中心位置转换为全局坐标
		var global_pos = navigation_layer.map_to_local(Vector2i(point))
		debug_line.add_point(global_pos)

# 获取导航路径*
func get_nav_path(start_cell: Vector2i, end_cell: Vector2i) -> PackedVector2Array:
	var id_start = calculate_point_index(start_cell)
	var id_end = calculate_point_index(end_cell)
	# 检查起点终点是否存在
	if not astar_node.has_point(id_start) or not astar_node.has_point(id_end):
		push_error("AstarComponent: Start or end point not in A* graph")
		return PackedVector2Array()
	# 获取路径
	var cell_path = astar_node.get_point_path(id_start, id_end)
	var global_path = PackedVector2Array()
	
	for cell in cell_path:
		# 转换为全局坐标（单元格中心）
		var global_pos = navigation_layer.map_to_local(Vector2i(cell)) 
		global_path.append(global_pos)
	
	return global_path

# 获取最近的有效点*
func get_closest_valid_point(position: Vector2) -> Vector2:
	var cell = navigation_layer.local_to_map(position)
	var point_index = calculate_point_index(cell)
	# 如果当前点有效，直接返回
	if astar_node.has_point(point_index):
		return navigation_layer.map_to_local(cell)
	# 搜索附近的点
	var closest_point = Vector2.ZERO
	var closest_distance = INF
	
	for id in astar_node.get_point_ids():
		var point_pos = astar_node.get_point_position(id)
		var global_pos = navigation_layer.map_to_local(Vector2i(point_pos)) 
		var distance = position.distance_to(global_pos)
		
		if distance < closest_distance:
			closest_distance = distance
			closest_point = global_pos
	
	return closest_point

# 清除调试路径
func clear_debug_path() -> void:
	debug_line.clear_points()
