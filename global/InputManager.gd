extends Node

#@export var walk_switch_to_open: GUIDEAction
#@export var open_switch_to_walk: GUIDEAction
#@export var bag_switch_to_walk: GUIDEAction
#@export var walk_switch_to_bag: GUIDEAction
#@export var shop_switch_to_walk: GUIDEAction
#@export var walk_switch_to_shop: GUIDEAction
#@export var dialogic_switch_to_walk: GUIDEAction
#@export var walk_switch_to_dialogic: GUIDEAction
#@export var battle_switch_to_walk: GUIDEAction
#@export var walk_switch_to_battle: GUIDEAction
#@export var global_key_and_mouse: GUIDEAction
#@export var global_controller: GUIDEAction
@export var global_key_and_mouse_context: GUIDEMappingContext
@export var global_controller_context: GUIDEMappingContext

@export var walk_mode: GUIDEMappingContext
@export var	open_mode: GUIDEMappingContext
@export var bag_mode: GUIDEMappingContext
@export var shop_mode: GUIDEMappingContext
@export var dialogic_mode: GUIDEMappingContext
@export var battle_mode: GUIDEMappingContext




#
#func action_trigger_connect() -> void:
	#walk_switch_to_open.triggered.connect(set_game_mode.bind(GameMode.OPEN_MODE))
	#open_switch_to_walk.triggered.connect(set_game_mode.bind(GameMode.WALK_MODE))
	#bag_switch_to_walk.triggered.connect(set_game_mode.bind(GameMode.WALK_MODE))
	#walk_switch_to_bag.triggered.connect(set_game_mode.bind(GameMode.BAG_MODE))
	#shop_switch_to_walk.triggered.connect(set_game_mode.bind(GameMode.WALK_MODE))
	#walk_switch_to_shop.triggered.connect(set_game_mode.bind(GameMode.SHOP_MODE))
	#dialogic_switch_to_walk.triggered.connect(set_game_mode.bind(GameMode.WALK_MODE))
	#walk_switch_to_dialogic.triggered.connect(set_game_mode.bind(GameMode.DIALOGIC_MODE))
	#battle_switch_to_walk.triggered.connect(set_game_mode.bind(GameMode.WALK_MODE))
	#walk_switch_to_battle.triggered.connect(set_game_mode.bind(GameMode.BATTLE_MODE))
#
	### 这部分代码会带来一些问题，需要手动启用
	##global_key_and_mouse.triggered.connect(_set_input_mode.bind(InputMode.KEYBOAED_AND_MOUSE))
	##global_controller.triggered.connect(_set_input_mode.bind(InputMode.CONTROALLER))



enum GameMode{
	WALK_MODE,
	OPEN_MODE,
	BAG_MODE,
	SHOP_MODE,
	DIALOGIC_MODE,
	BATTLE_MODE,
}

var _game_mode: GameMode = GameMode.WALK_MODE

enum InputMode {
	KEYBOAED_AND_MOUSE,
	CONTROALLER,
}


var _input_mode: InputMode = InputMode.KEYBOAED_AND_MOUSE





func set_game_mode(game_mode: GameMode):
	_game_mode = game_mode
	_update_input()

func set_input_mode(input_mode: InputMode):
	_input_mode = input_mode
	_update_input()

func _update_input():
	if global_controller_context == null || global_key_and_mouse_context == null:
		return
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	match _input_mode:
		InputMode.KEYBOAED_AND_MOUSE:
			GUIDE.enable_mapping_context(global_key_and_mouse_context, true)	##true确保其他的context不被引用
			match _game_mode:
				GameMode.OPEN_MODE:
					GUIDE.enable_mapping_context(open_mode)
					#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE	##鼠标可视化
				GameMode.WALK_MODE:
					GUIDE.enable_mapping_context(walk_mode)
					#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				GameMode.BAG_MODE:
					GUIDE.enable_mapping_context(bag_mode)
					#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE					
				GameMode.SHOP_MODE:
					GUIDE.enable_mapping_context(shop_mode)
					#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				GameMode.DIALOGIC_MODE:
					GUIDE.enable_mapping_context(dialogic_mode)
					#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				GameMode.BATTLE_MODE:
					GUIDE.enable_mapping_context(battle_mode)
					#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		InputMode.CONTROALLER:
			GUIDE.enable_mapping_context(global_controller_context, true)
			match  _game_mode:
				GameMode.OPEN_MODE:
					GUIDE.enable_mapping_context(open_mode)
				GameMode.WALK_MODE:
					GUIDE.enable_mapping_context(walk_mode)
					
