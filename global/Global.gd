extends Node
var current_astar_path = {}
var TILE_SIZE = Vector2(16, 16)
var enemy_scenes: Dictionary = {
	"ghost": 'res://character/enemy/ghost.tscn',
	"skeleton": 'res://character/enemy/skeleton.tscn',
	"bat": "res://character/enemy/bat.tscn",
	"bat2": "res://character/enemy/bat2.tscn",
	"skeleton_guard": "res://character/enemy/skeleton_guard.tscn",
	"sorcerer": 'res://character/enemy/sorcerer.tscn',
	"giant": 'res://character/enemy/giant.tscn',
	"ghost2": 'res://character/enemy/ghost_2.tscn',
	"dog": 'res://character/npc/dog.tscn',
	"devil": 'res://character/npc/dog.tscn',
	"fiona": 'res://character/npc/fiona.tscn',
	"pharmaceutist": 'res://character/npc/pharmaceutist.tscn',
	"wandering_ghost": 'res://character/npc/wandering_ghost.tscn',
}	

var item_scenes: Dictionary = {
	"healing_potion": 'res://interact/potion/healing_potion.tscn',
	"yellow_key": 'res://interact/key/yellow_key.tscn',
	"blue_key": 'res://interact/key/blue_key.tscn',
	"red_key": 'res://interact/key/red_key.tscn',
	"yellow_door": 'res://interact/door/yellow_door.tscn',
	"dagger": 'res://interact/equipment/dagger.tscn',
	"green_crystal": "res://interact/crystal/green_crystal.tscn",
	"red_crystal": "res://interact/crystal/red_crystal.tscn",
	"secret_step": 'res://interact/step/secret_step.tscn',
	"trap": 'res://interact/trap/trap.tscn',
	"book_shelf": 'res://interact/shelf/book_shelf.tscn',
	"mana_potion": 'res://interact/potion/mana_potion.tscn',
}

var door_scenes: Dictionary = {
	"yellow_door": 'res://interact/door/yellow_door.tscn',
	"red_door": 'res://interact/door/red_door.tscn',
	"blue_door": 'res://interact/door/blue_door.tscn',
	"white_door": 'res://interact/door/white_door.tscn',
}

var npc_scenes: Dictionary = {
	"pharmaceutist": 'res://character/npc/pharmaceutist.tscn',
	"dog": 'res://character/npc/dog.tscn',
	"wandering_ghost": 'res://character/npc/wandering_ghost.tscn',
	"fiona": "res://character/npc/fiona.tscn",
	
}

var ui_scenes: Dictionary = {
	"bag": 'res://ui/inventory/inventory_ui.tscn',
	"shop": 'res://ui/inventory/shop_ui.tscn',
	"battle": 'res://ui/battle/battle_ui.tscn',
	"main_menu": 'res://ui/menu/main_menu.tscn',
	"skill": 'res://ui/skill/skill_ui.tscn',
	"craft": 'res://ui/craft/craft_ui.tscn',

}

var dialogue_texture: Dictionary = {
	"player": "res://asserts/image/character/yongzhe-01.png",
	"mowang": "res://asserts/image/character/mowang-01.png",
	"yaojishi": "res://asserts/image/character/yaojishi-01.png",
	"shen": "res://asserts/image/character/shen-01.png",
	"ghost": "res://asserts/image/character/ghost-01.png",
	"emo": "res://asserts/image/character/emo-01.png",
	"dog": "res://asserts/image/character/dog-0001.png",
}

var play_scene: String = 'res://character/player/player.tscn'

var icon_dict: Dictionary = {
	"defense": preload('res://asserts/image/icon/icon_defence.png'),
	"gold": preload('res://asserts/image/icon/icon_gold.png'),
	"health": preload('res://asserts/image/icon/icon_health.png'),
	"magic": preload('res://asserts/image/icon/icon_magic.png'),
	"attack": preload('res://asserts/image/icon/icon_hit.png'),
	"yellow_key": preload('res://asserts/image/icon/icon_yellow_key.png'),
	"blue_key": preload('res://asserts/image/item/icon_blue_key.png'),
	"red_key": preload('res://asserts/image/icon/icon_red_key.png'),
	"player": preload('res://asserts/image/icon/icon_player.png')
	
}

var global_input_map: Dictionary = {
	"global_key": preload("res://input/GlobalKeyboardMouse.tres"),
	"global_controller": preload("res://input/GlobalController.tres"),
	"switch_to_controller": preload("res://input/switch_to_controller.tres"),
	"switch_to_keyboard_and_mouse": preload("res://input/switch_to_keyboard_and_mouse.tres"),
}

var input_action_map: Dictionary = {
	"bag_switch_to_walk": preload("res://input/bag/bag_switch_to_walk.tres"),
	"dialogic_switch_to_walk": preload("res://input/dialogic/dialogic_switch_to_walk.tres"),
	"open_swith_to_walk": preload("res://input/menu/open_swith_to_walk.tres"),
	"walk_switch_to_dialogic": preload("res://input/walk/walk_switch_to_dialogic.tres"),
	"walk_switch_to_bag": preload("res://input/walk/walk_switch_to_bag.tres"),
	"walk_switch_to_open": preload("res://input/walk/walk_switch_to_open.tres"),
#	"move": preload("res://input/walk/move.tres"),

}
var input_action_gamemode: Dictionary = {
	"bag_switch_to_walk": InputManager.GameMode.WALK_MODE,
	"battle_switch_to_walk": InputManager.GameMode.WALK_MODE,
	"dialogic_switch_to_walk": InputManager.GameMode.WALK_MODE,
	"open_swith_to_walk": InputManager.GameMode.WALK_MODE,
	"walk_switch_to_dialogic": InputManager.GameMode.DIALOGIC_MODE,
	"walk_switch_to_bag": InputManager.GameMode.BAG_MODE,
	"walk_switch_to_open": InputManager.GameMode.OPEN_MODE,
	"switch_to_controller": InputManager.GameMode.WALK_MODE,
	"switch_to_keyboard_and_mouse": InputManager.GameMode.WALK_MODE,
}

var input_context_map: Dictionary = {
	"walk_mode": preload("res://input/walk/walk_mode.tres"),
	"open_mode": preload("res://input/menu/open_mode.tres"),
	"dialogic_mode": preload("res://input/dialogic/dialogic_mode.tres"),
	"bag_mode": preload("res://input/bag/bag_mode.tres"),
	
}



var game_started: bool = false

var language: String = "en"
var map_path: String = 'res://map/'
var world: Node2D
var input_manager: InputManager

## audio
var can_play_audio_effect: bool = true
var can_play_audio_background: bool = true
var current_background: String = "menu"
### 狗的相关全局参数
#var can_battle_p: bool = false
#var dog_dialogue_title: String = "start"
#var dog_die: bool = false
#
#
### 药剂师的相关全局参数
#var can_battle_dog: bool = false
#var friend_with_p: bool = false
#var p_die: bool = false
#var p_dialogue_title: String = "start"
#var p_total_gold: int:
	#set(v):
		#p_total_gold = v
		#if p_total_gold >= 200 and !friend_with_p:
			#p_dialogue_title = "friend"
			#friend_with_p = true
			#LogManager.add_entry("消费达标，获得了药剂师的友谊")

##
var is_entering: bool = false
## 屏幕大小
var screen_size
var player: Player

## buffer
var buffer_id: Dictionary

## 结局相关
var memory: int = 0
var last_end: String = ""
var unlocked_endings: Dictionary = {
	"die": false,
	"be": false,
	"he": false,
	"te": false,
	"gd": false,
}
var end: String = "die"
var die_count: int = 0
var meet_p: int = 0
var interacting: bool = false

# 生成唯一ID
func generate_unique_id() -> String:
	return "item_%s_%d" % [str(randi() % 10000).pad_zeros(4), Time.get_ticks_msec()]

var npc_dict: Dictionary = {
}


func check_consume() -> bool:
	if npc_dict.get("phar").get("gold") >= 300:
		LogManager.add_entry(tr("log_spend_target_reached"))
		return true
	return false


func npc_init() -> void:
	var npc_dict_data: Dictionary = {
		"dog": {},
		"phar": {},
		"brave": {},
		"wandering_ghost": {},
		"fiona": {},
		
	}
	npc_dict = npc_dict_data
	for npc in npc_dict:
		if npc_dict.get(npc).is_empty():
			var dict = npc_dict.get(npc)
			dict.set("dialogue_title", "start")
			dict.set("die", false)
			dict.set("friend_with_player", false)
			dict.set("can_battle", false)
	npc_dict.get("phar").set("gold", 0)
	npc_dict.get("dog").set("have_potion", false)


func get_can_battle(_npc: String) -> bool:
	return npc_dict.get(_npc).get("can_battle")

func get_die(_npc: String) -> bool:
	return npc_dict.get(_npc).get("die")

func get_dialogue_title(_npc: String) -> String:
	return npc_dict.get(_npc).get("dialogue_title")

func get_friend_with_player(_npc: String) -> bool:
	return npc_dict.get(_npc).get("friend_with_player")

func set_npc_dialogue_title(_npc: String, _title: String) -> void:
	npc_dict.get(_npc).set("dialogue_title", _title)

func set_npc_die(_npc: String, _tag: bool) -> void:
	npc_dict.get(_npc).set("die", _tag)

func set_npc_can_battle(_npc: String, _tag: bool) -> void:
	npc_dict.get(_npc).set("can_battle", _tag)

func set_npc_friend_with_player(_npc: String, _tag: bool) -> void:
	npc_dict.get(_npc).set("friend_with_player", _tag)

func _ready():
	# 初始化本地化系统 - 同步 Global.language 与 TranslationServer
	TranslationServer.set_locale(language)
	
	# 加载持久化数据（结局成就等）
	load_persist_data()
	
	# 获取屏幕尺寸
	SignalManager.start_game.connect(_on_start_game)
	SignalManager.end_game.connect(_on_end_game)
	#SignalManager.load_game.connect(_on_load_game)
	screen_size = get_viewport().get_visible_rect().size


## 设置游戏语言，同时更新 Global.language 和 Godot 的 TranslationServer
func set_language(lang: String) -> void:
	language = lang
	TranslationServer.set_locale(lang)
	# 重新加载模板以更新物品/技能/角色名称
	_update_template_language()


## 更新所有模板的显示语言
func _update_template_language() -> void:
	# 遍历所有已注册的模板，刷新 display_name
	for tid in ItemFactory._templates:
		var t = ItemFactory._templates[tid]
		if t and t.has_method("update_display_name"):
			t.update_display_name()
	for tid in SkillFactory._templates:
		var t = SkillFactory._templates[tid]
		if t and t.has_method("update_display_name"):
			t.update_display_name()
	for tid in CraftFactory._templates:
		var t = CraftFactory._templates[tid]
		if t and t.has_method("update_display_name"):
			t.update_display_name()
	for tid in CharacterFactory._templates:
		var t = CharacterFactory._templates[tid]
		if t and t.has_method("update_display_name"):
			t.update_display_name()


func get_data() -> Dictionary:
	var data: Dictionary = {}
	data.set("plot", npc_dict)
	data.set("can_play_audio_effect", can_play_audio_effect)
	#data.set("current_background", current_background)
	data.set("can_play_audio_background", can_play_audio_background)
	data.set("memory", memory)
	return data

func set_data(data: Dictionary) -> void:
	
	npc_dict = data.get("plot", {})
	can_play_audio_background = data.get("can_play_audio_background")
	can_play_audio_effect = data.get("can_play_audio_effect")
	memory = data.get("memory", 0)
	#current_background = data.get("current_background")
	
func save_persist_data() -> void:
	var persist_data: Dictionary = {}
	persist_data.set("die_count", die_count) 
	persist_data.set("last_end", last_end)
	persist_data.set("unlocked_endings", unlocked_endings)
	special_save(persist_data)
	


func load_persist_data() -> void:
	var persist_data: Dictionary = special_load()
	if persist_data.is_empty():
		return
	die_count = persist_data.get("die_count")
	if persist_data.has("last_end"):
		last_end = persist_data.get("last_end")
	if persist_data.has("unlocked_endings"):
		for key in persist_data["unlocked_endings"]:
			unlocked_endings[key] = persist_data["unlocked_endings"][key]
	
	
func clear() -> void:
	game_started = false
	npc_dict.clear()
	memory = 0
	last_end = ""
	# unlocked_endings 保留不清空，这是跨存档的成就记录


func special_save(data: Dictionary) -> void:
	var file = FileAccess.open("user://global_save.bin", FileAccess.WRITE)
	file.store_var({
		"header": "MYSAVE",
		"version": 0.1,
		"data": data
	})
	file.close()

func special_load() -> Dictionary:
	var file = FileAccess.open("user://global_save.bin", FileAccess.READ)
	if file and file.get_length() > 0:
		var save_data: Dictionary = file.get_var()
		if save_data["header"] == "MYSAVE":
			return save_data["data"]
	return {}



func bad_ending() -> void:
	if is_instance_valid(Global.player):
		Global.player.queue_free()
	SignalManager.play_dialogue_with.emit(null, "be")
	Global.last_end = "be"
	Global.save_persist_data()

func good_ending() -> void:
	SignalManager.play_dialogue_with.emit(null, "he")
	Global.last_end = "he"
	Global.save_persist_data()

func true_ending() -> void:
	SignalManager.play_dialogue_with.emit(null, "te")
	Global.last_end = "te"
	Global.save_persist_data()

func god_ending() -> void:
	if is_instance_valid(Global.player):
		Global.player.queue_free()
	SignalManager.play_dialogue_with.emit(null, "die")
	Global.last_end = "gd"
	Global.save_persist_data()

func die_ending() -> void:
	if is_instance_valid(Global.player):
		Global.player.queue_free()
	SignalManager.play_dialogue_with.emit(null, "die")
	Global.last_end = "die"
	Global.save_persist_data()

func _on_start_game(_v = null) -> void:
	npc_init()

#func _on_load_game(_v = null) -> void:
	#
	#npc_init()


func _on_end_game(_type: String="die") -> void:
	
	InputManager.set_game_mode(InputManager.GameMode.DIALOGIC_MODE)
	var game_over_scene = load('res://ui/game_over_scene.tscn').instantiate() 
	add_child(game_over_scene)
	for action_key in Global.input_action_map:
		if input_action_map[action_key].triggered.is_connected(InputManager.set_game_mode.bind(\
		input_action_gamemode[action_key])):
			input_action_map[action_key].triggered.disconnect(InputManager.set_game_mode.bind(\
			input_action_gamemode[action_key]))
	DialogueManager.get_current_scene = func():
		return self
	
	match _type:
		"die": 
			unlocked_endings["die"] = true
			die_ending()
		"gd": 
			unlocked_endings["gd"] = true
			god_ending()
		"he": 
			unlocked_endings["he"] = true
			good_ending()
		"be": 
			unlocked_endings["be"] = true
			bad_ending()
		"te": 
			unlocked_endings["te"] = true
			true_ending()
	clear()
	await DialogueManager.dialogue_ended
	game_over_scene.queue_free()
	get_tree().change_scene_to_file("res://main.tscn")
