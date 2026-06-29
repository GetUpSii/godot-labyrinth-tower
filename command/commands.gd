extends Node
class_name CommandRegistry

# ===== 命令接口 =====
class ICommand:
	extends RefCounted
	func execute() -> void:
		pass

# ===== 通用移动命令 =====
class MoveCommand:
	extends ICommand
	var receiver
	var dir
	func _init(_receiver, _dir):
		receiver = _receiver
		dir = _dir
	func execute():
		if receiver and receiver.has_method("move_in_direction"):
			receiver.move_in_direction(dir)

# ===== 跳跃命令 =====


# ===== 通用的打开命令（支持传参）=====
class OpenBagCommand: 
	extends ICommand 
	var receiver 
	func _init(_receiver): 
		receiver = _receiver 
	func execute(): 
		if receiver and receiver.has_method("open_bag"): 
				receiver.open_bag()

class OpenMenuCommand: 
	extends ICommand 
	var receiver 
	func _init(_receiver): 
		receiver = _receiver 
	func execute(): 
		if receiver and receiver.has_method("open"): 
				receiver.open()


func register_all(input_manager, receiver):
	var contexts = {
		"player": {
			"key_up": MoveCommand.new(receiver, "up"),
			"key_down": MoveCommand.new(receiver, "down"),
			"key_left": MoveCommand.new(receiver, "left"),
			"key_right": MoveCommand.new(receiver, "right"),
			"open_bag": OpenBagCommand.new(receiver)
		},
		#"ui": {
			#"open_bag": OpenBagCommand.new(receiver)
		#}
	}

	for ctx in contexts.keys():
		for action in contexts[ctx].keys():
			var continuous = action.begins_with("key_")
			input_manager.register_command(ctx, action, contexts[ctx][action], continuous)
