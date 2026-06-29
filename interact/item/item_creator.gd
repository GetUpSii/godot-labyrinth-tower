extends Node2D
class_name ItemCreator



func initialize() -> void:
	for item: Item in get_tree().get_nodes_in_group(&'item'):
		item.initialize()
