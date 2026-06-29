extends Node

var current_level: LevelMap
var world: Node2D
var levels_path: String
var level_changing: bool = false
var levels_data: Dictionary
var _just_teleported: bool = false
@export var dialogue: DialogueResource = load('res://resource/dialogue/level.dialogue')
##解析当前的level,如果

func clear() -> void:
	levels_data.clear()

func get_data() -> Dictionary:
	save_level()
	var data: Dictionary = {}
	data.set("map", levels_data)
	data.set("current_level", current_level.level_id)
	return data

func set_data(data: Dictionary) -> void:
	levels_data = data.get("map")
	print(levels_data)
	var current_level_id: int = data.get("current_level")
	var level: LevelMap
	if current_level_id == -5:
		level = load('res://map/secret_room.tscn').instantiate() as LevelMap
	else:
		level = load(levels_path+"level_" + str(current_level_id) + ".tscn").instantiate() as LevelMap
	for child in world.get_children():
		child.queue_free()
	world.add_child(level)
	current_level = level
	get_tree().paused = true
	await get_tree().create_timer(0.01).timeout
	level.set_data()	
	level.init_navigator()
	get_tree().paused = false
	if current_level_id == -5:
			SignalManager.play_dialogue_with.emit(dialogue, "secret_room")
			return
	SignalManager.play_dialogue_with.emit(dialogue, "level"+ str(current_level.level_id))

func up_secret_room(_player: Player) -> void:
	if level_changing:
		return
	level_changing = true
	# 切换前从场景树移除玩家
	var player_parent = _player.get_parent()
	player_parent.remove_child(_player)
	var new_level: LevelMap = load('res://map/secret_room.tscn').instantiate() as LevelMap
	if new_level == null:
		push_error("find no level up")
		return
	## 168, 88
	_player.global_position = Vector2(184, 88)
	world.add_child(new_level)
	register_level(new_level)
	load_level(new_level)
	# 切换完成后恢复玩家
	player_parent.add_child(_player)
	SignalManager.play_dialogue_with.emit(dialogue, "secret_room")

func down_secret_room(_player: Player) -> void:
	if level_changing:
		return
	level_changing = true
	# 切换前从场景树移除玩家
	var player_parent = _player.get_parent()
	player_parent.remove_child(_player)
	var new_level: LevelMap = load(levels_path + "level_5" + ".tscn").instantiate() as LevelMap
	if new_level == null:
		push_error("find no level up")
		return
	_player.global_position = Vector2(104, 56)
	world.add_child(new_level)
	register_level(new_level)
	load_level(new_level)
	# 切换完成后恢复玩家
	player_parent.add_child(_player)
	SignalManager.play_dialogue_with.emit(dialogue, "level"+ str(current_level.level_id))

func up_level(_player: Player) -> void:
	if level_changing:
		return
	level_changing = true
	# 切换前从场景树移除玩家，防止按键残留
	var player_parent = _player.get_parent()
	player_parent.remove_child(_player)
	var id: int = current_level.level_id + 1
	var new_level: LevelMap = load(levels_path+"level_" + str(id) + ".tscn").instantiate() as LevelMap
	if new_level == null:
		push_error("find no level up")
		return
	world.add_child(new_level)
	register_level(new_level)
	load_level(new_level)
	# 切换完成后恢复玩家
	player_parent.call_deferred("add_child", _player)
	SignalManager.play_dialogue_with.emit(dialogue, "level"+ str(current_level.level_id))


#func load_level() -> void:
	#current_level.call_deferred("get_data")
func load_level(node) -> void:
	get_tree().paused = true
	await get_tree().create_timer(0.01).timeout
	node.set_data()	
	get_tree().paused = false

func save_level() -> void:
	## 检测当前场景的怪物
	get_tree().paused = true	 ##写入保护，以确保数据全部保存，在此期间，游戏静止
	print("save level ", current_level.level_id)
	levels_data.set(current_level.level_id, current_level.get_data())
	await get_tree().create_timer(0.01).timeout
	get_tree().paused = false

func down_level(_player: Player) -> void:
	if level_changing:
		return
	level_changing = true
	# 切换前从场景树移除玩家，防止按键残留
	var player_parent = _player.get_parent()
	player_parent.remove_child(_player)
	var id: int = current_level.level_id - 1
	var new_level: LevelMap = load(levels_path+"level_" + str(id) + ".tscn").instantiate() as LevelMap
	if new_level == null:
		push_error("find no level down")
		return	
	world.add_child(new_level)
	register_level(new_level)
	load_level(new_level)
	# 切换完成后恢复玩家
	player_parent.call_deferred("add_child", _player)
#	player_parent.add_child(_player)

## path1: world path, path2: levels storage path
func register_path(node: Node2D,  path2: String) -> void:
	world = node
	levels_path = path2

## 注册关卡
func register_level(v: LevelMap) -> void:
	if current_level != null:
		## 保存当前场景的数据
		save_level()
		current_level.queue_free()
	current_level = v
	current_level.initialiaze()
	_just_teleported = true
	# 等两帧让物理碰撞稳定后清除标记，避免玩家走到楼梯时被误拦
	_clear_just_teleported.call_deferred()

func _clear_just_teleported() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_just_teleported = false

func _all_scenes_loaded() -> void:
	current_level.set_data()

## 返回当前的关卡
func get_current_level() -> LevelMap:
	return current_level


func remove_object(pos: Vector2) -> void:
	current_level.call_deferred("remove_obstacle", pos)
	#current_level.remove_obstacle(pos)

## 移除关卡
func unregister_level() -> void:
	print("unregister level %s", current_level.level_id)
