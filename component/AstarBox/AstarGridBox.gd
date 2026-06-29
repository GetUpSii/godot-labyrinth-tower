class_name AdvancedAStarNavigator
extends Node2D

## 增强版寻路组件（支持多障碍层）
## 使用说明：
## 1. 设置floor_layer作为基础层
## 2. 使用add_obstacle_layer()添加障碍层
## 3. 调用find_path()进行寻路

signal path_found(path: PackedVector2Array)
signal path_finished()
signal obstacle_updated()

@export var floor_layer: TileMapLayer
@export var move_speed: float = 150.0
@export var draw_path: bool = true
@export var path_color: Color = Color.ROYAL_BLUE
@export var path_width: float = 2.0

var astar: AStarGrid2D = AStarGrid2D.new()
var current_path: PackedVector2Array = []
var current_path_index: int = 0
var is_moving: bool = false
var obstacle_layers: Array[TileMapLayer] = []
var dynamic_obstacles: Array[Vector2i] = []
#
#signal astar_find_path_finished



#func use():
	## 设置基础层
	#navigator.floor_layer = navigation_layer
	#
	## 添加多个障碍层
	#navigator.add_obstacle_layer(building_layer)
	### 添加动态障碍（例如移动的敌人）
	##var enemy_cell = Vector2i(5, 5)
	##navigator.add_dynamic_obstacle(enemy_cell)


func initialize_astar():
	if not floor_layer or not floor_layer.tile_set:
		push_error("Floor layer or tile set not set!")
		return
	
	var tile_size = floor_layer.tile_set.tile_size
	astar.region = floor_layer.get_used_rect()
	
	astar.cell_size = tile_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.update()
	
	update_all_obstacles()
	obstacle_updated.emit()
	set_process(false)

## 添加障碍层
func add_obstacle_layer(layer: TileMapLayer):
	if not obstacle_layers.has(layer):
		obstacle_layers.append(layer)

## 移除障碍层
func remove_obstacle_layer(layer: TileMapLayer):
	obstacle_layers.erase(layer)
	update_all_obstacles()

## 添加动态障碍（网格坐标）
func add_dynamic_obstacle(cell: Vector2i):
	if not dynamic_obstacles.has(cell):
		dynamic_obstacles.append(cell)
		astar.set_point_solid(cell, true)
		obstacle_updated.emit()



## 移除动态障碍
func remove_dynamic_obstacle(cell: Vector2i):
	if astar.region.size == Vector2i.ZERO:
		push_error("AStar grid region is not initialized or empty.")
		return
	if not astar.region.has_point(Vector2(cell)):
		push_warning("Tried to add dynamic obstacle at %s which is outside the grid." % cell)
		return
	if dynamic_obstacles.has(cell):
		astar.set_point_solid(cell, false)
		dynamic_obstacles.erase(cell)
		obstacle_updated.emit()

## 清除所有障碍
func clear_all_obstacles():
	for cell in astar.get_points():
		astar.set_point_solid(cell, false)
	obstacle_layers.clear()
	dynamic_obstacles.clear()
	obstacle_updated.emit()

## 更新所有障碍（包括静态和动态）
func update_all_obstacles():
	print(astar.region)
	# 清除现有障碍
	astar.fill_solid_region(astar.region, false)
	
	# 添加静态障碍层
	for layer in obstacle_layers:
		for cell in layer.get_used_cells():
			astar.set_point_solid(cell, true)
	
	# 添加动态障碍
	for cell in dynamic_obstacles:
		astar.set_point_solid(cell, true)
	
	if draw_path:
		queue_redraw()

func find_path(start_pos: Vector2, target_pos: Vector2, _v: bool = false) -> PackedVector2Array:
	if not floor_layer:
		return []
	
	# 坐标转换
	var local_start = floor_layer.to_local(start_pos)
	var local_target = floor_layer.to_local(target_pos)
	
	var start_cell = floor_layer.local_to_map(local_start)
	var target_cell = floor_layer.local_to_map(local_target)
	
	if astar.is_point_solid(start_cell) or astar.is_point_solid(target_cell):
		return []
	
	var grid_path = astar.get_id_path(start_cell, target_cell, _v)
	current_path = convert_grid_to_world_path(grid_path)
	current_path_index = 0
	is_moving = true
	set_process(true)
	
	path_found.emit(current_path)
	
	if draw_path:
		queue_redraw()
	
	return current_path





func convert_grid_to_world_path(grid_path: PackedVector2Array) -> PackedVector2Array:
	var world_path = PackedVector2Array()
	for cell in grid_path:
		var local_pos = floor_layer.map_to_local(cell)
		var global_pos = floor_layer.to_global(local_pos)
		world_path.append(global_pos)
	return world_path

#func _process(delta: float):
	#if current_path_index >= current_path.size():
		#is_moving = false
		#set_process(false)
		#path_finished.emit()
		#return
	#
#
#func _draw():
	#if not draw_path or current_path.size() < 2:
		#return
	#
	## 转换到本地坐标系绘制
	#var local_path = PackedVector2Array()
	#for point in current_path:
		#local_path.append(to_local(point))
	#
	## 绘制路径线
	#for i in range(local_path.size() - 1):
		#draw_line(local_path[i], local_path[i+1], path_color, path_width)
	#
	## 绘制路径点
	#for point in local_path:
		#draw_circle(point, path_width * 2, path_color.lightened(0.3))
	#
	## 标记起点终点
	#if local_path.size() > 0:
		#draw_circle(local_path[0], path_width * 3, Color.LIME)
		#draw_circle(local_path[-1], path_width * 3, Color.ORANGE)
