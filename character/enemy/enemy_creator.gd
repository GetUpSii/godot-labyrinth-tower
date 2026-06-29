extends Node2D
class_name EnemyCreator



func initialize() -> void:
	for enemy: Character2d in get_tree().get_nodes_in_group(&'enemy'):
		if enemy:
			enemy.initialize()
	var npc_group = get_tree().get_first_node_in_group(&'npc')
	if npc_group:
		for npc in npc_group:
			npc.initialize()
