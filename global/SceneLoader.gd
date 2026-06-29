# SceneLoader.gd
# 场景就绪通知工具，用于需要等待场景完全加载的场景
extends Node

signal all_scenes_loaded

func await_full_load(scene: Node):
	# 如果场景已经在树中且就绪，直接返回
	if scene.is_inside_tree() and scene.is_node_ready():
		return
	# 否则等它进入树
	if not scene.is_inside_tree():
		await scene.tree_entered
	await get_tree().process_frame
	all_scenes_loaded.emit()
