extends Node

@onready var player_creator: PlayerCreator = $PlayerCreator
@export var start_dialogue: DialogueResource

@onready var world: Node2D = $World

#@onready var player: Player = $PlayerCreator/Player
@onready var user_interface: CanvasLayer = $UserInterface
@onready var back_ground_audio: AudioStreamPlayer = $AudioBackground
@onready var audio_effect: AudioStreamPlayer = $AudioEffect

var level_id: int = 1
var dialogue_balloon: DialogueBalloonA

## 设置状态  开始状态， 游戏进行中状态


func init_map() -> void:
	LevelManager.register_path(world, Global.map_path)
	var level_1: LevelMap = load('res://map/level_1.tscn').instantiate() as LevelMap
	level_1.name = "level_1"
	world.add_child(level_1)
	LevelManager.register_level(level_1)

func init_template() -> void:
	## 对character进行初始化，导入数据
	CharacterFactory.initialize()
	if CharacterFactory.get_template("ghost2"):
		print("人物模板初始化完成")	
	ItemFactory.initialize()
	if ItemFactory.get_template("healing_potion"):
		print("物品模板初始化完成")	
	SkillFactory.initialize()
	if SkillFactory.get_template("fileball"):
		print("技能模板初始化完成")
	CraftFactory.initialize()
	if CraftFactory.get_template("healing_potion"):
		print("配方模板初始化完成")


func signal_connect() -> void:
	SignalManager.play_dialogue_with.connect(play_dialogue)
	SignalManager.start_game.connect(_on_start_game)
	SignalManager.load_game.connect(_on_load_game)
	SignalManager.on_change_audio_background.connect(set_audio)
	SignalManager.on_change_audio_effect.connect(set_audio_effect)
	SignalManager.on_set_dialogue_texture.connect(set_dialogue_texture)

func init_player() -> void:
	var start_player: Player = load("res://character/player/player.tscn").instantiate() as Player
	start_player.global_position =  Vector2(104, 151)
	Global.player = start_player
	player_creator.initialize(start_player)
	player_creator.add_child(start_player)


func _ready() -> void:
	init_template()
	signal_connect()
	Global.world = world

	set_audio("menu")
	init_inputmap()

# 测试用：按 L 键切换中英文
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_L:
		if Global.language == "zh":
			Global.set_language("en")
			print(">> Language switched to: English")
		else:
			Global.set_language("zh")
			print(">> 语言切换到：中文")

var audio_dict: Dictionary = {
	"default": "res://asserts/bgm/background1.mp3",
	"battle": "res://asserts/bgm/background2.mp3",
	"menu": "res://asserts/bgm/crystal-cave-song18.mp3",
	"phar": "res://asserts/bgm/backgroundp.mp3",
}
var audio_effect_dict: Dictionary = {
	"key": 'res://asserts/sfx/item/keys_07.ogg',
	"door": 'res://asserts/sfx/item/doorOpen_1.ogg',
	"inventory": 'res://asserts/sfx/item/cloth-inventory.wav',
	"potion": 'res://asserts/sfx/item/bubble.wav',
	"walk": 'res://asserts/sfx/character/footstep06.ogg',
	"attack": 'res://asserts/sfx/item/swing.wav',
	"applause": 'res://asserts/sfx/other/applause.mp3',
	"disapproval": 'res://asserts/sfx/other/disapproval.mp3',
}

func init_inputmap() -> void:
	InputManager.global_controller_context = Global.global_input_map["global_controller"]
	InputManager.global_key_and_mouse_context = Global.global_input_map["global_key"]
	InputManager.open_mode = Global.input_context_map["open_mode"]
	InputManager.walk_mode = Global.input_context_map["walk_mode"]
	InputManager.dialogic_mode = Global.input_context_map["dialogic_mode"]
	InputManager.bag_mode = Global.input_context_map["bag_mode"]

	for action_key in Global.input_action_map:
		Global.input_action_map[action_key].triggered.connect(InputManager.set_game_mode.bind(\
		Global.input_action_gamemode[action_key]))

func set_audio(v: String) -> void:
	Global.current_background = v
	if Global.can_play_audio_background:
		back_ground_audio.stream = load(audio_dict.get(Global.current_background))
		back_ground_audio.play()
	else:
		back_ground_audio.stream_paused = true

func set_audio_effect(v: String = "key") -> void:
	if Global.can_play_audio_effect:
		audio_effect.stream = load(audio_effect_dict.get(v))
		audio_effect.play()
	else:
		audio_effect.stream_paused = true



func _on_load_game(_v) -> void:
	player_creator.show()
	set_audio("default")

func _on_start_game(_v) -> void:
	init_map()
	init_player()
	player_creator.show()
	set_audio("default")
	play_dialogue(start_dialogue,"start")

func set_dialogue_texture(dialogue_user: String) -> void:
	if dialogue_user == "":
		dialogue_balloon.set_texture(dialogue_user, null)
		return
	var texture: Texture2D = load(Global.dialogue_texture.get(dialogue_user)) as Texture2D
	dialogue_balloon.set_texture(dialogue_user, texture)

func play_dialogue(dialogue: DialogueResource = start_dialogue, title: String = "", _value: int = 0) -> void:
	InputManager.set_game_mode(InputManager.GameMode.DIALOGIC_MODE)
	if title == "":
		return
	if dialogue_balloon == null:
		dialogue_balloon = preload('res://ui/dialogue/dialogue_balloon.tscn').instantiate()
		get_tree().root.add_child(dialogue_balloon)
		set_dialogue_texture("")
	if dialogue == null:
		dialogue = start_dialogue
	##disable_collision(true)
  # 准备要传递的游戏状态对象（通常是包含游戏数据的节点）
   ## var game_states = [$Player, $Inventory, $QuestSystem]
	var game_states = []
	# 启动对话并传递状态
	dialogue_balloon.start(dialogue, title , game_states)
	InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)
	set_dialogue_texture("")
