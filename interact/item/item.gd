extends StaticBody2D
class_name Item
@export var type: String
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var instance: ItemInstance


## 初始化
func initialize() -> void:
	add_to_group(&'item')
	self.instance = ItemFactory.create_item(type)
	
## 装备
func equip(_player: Player) -> void:
	pass


func unequip(_player: Player) -> void:
	pass

func get_data() -> Dictionary:
	if not instance:
		push_warning("实例为空")
		return {}
	# 只保存差异数据
	var data: Dictionary = {}
	data.set("instance", instance.get_data())
	data.set("position", global_position)
	data.set("template_id", instance.get_template_id())
	return data

func set_data(data: Dictionary) -> void:
	instance = ItemFactory.create_item(data["template_id"])
	instance.set_data(data.get("instance"))
	global_position = data.get("position")



## 消耗品使用
func use(_player: Player) -> void:
	pass

func on_player_interact(_player: Player) -> void:

	pass
