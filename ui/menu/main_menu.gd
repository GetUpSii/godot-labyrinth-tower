extends Control
class_name MainMenu
@onready var save_button: Button = %SaveButton
@onready var start_button: Button = %StartButton
@onready var load_button: Button = %LoadButton
@onready var setting_button: Button = %SettingButton
@onready var exit_button: Button = %ExitButton
@onready var continue_button: Button = %ContinueButton
@onready var tip_label: Label = %TipLabel
@onready var button_container = %ButtonContainer





# 按钮配置字典：按钮节点引用 -> 显示条件函数
func _update_menu_state():
	var game_active = Global.game_started
	# 基础按钮显隐逻辑
	save_button.visible = game_active
	continue_button.visible = game_active
	start_button.visible = !game_active
#	load_button.visible = game_active
	# 始终显示的按钮不需要设置
	# 自动焦点管理
	if game_active:
		load_button.grab_focus()
	else:
		start_button.grab_focus()






func _ready() -> void:
	# 动态连接所有按钮信号
	for button in button_container.get_children():
		if button is Button:
		#if button.is_connected("pressed", Callable(self, "_on_button_pressed")):
			#continue
			button.pressed.connect(_on_button_pressed.bind(button))
	_update_menu_state()


func grab() -> void:
	if button_container.get_child(0):
		button_container.get_child(0).grab_focus()
	


# 统一按钮处理
func _on_button_pressed(button: Button):
	match button:
		save_button:
			save_game()
		start_button:
			start_game()
		load_button:
			load_game()
		setting_button:
			setting_game()
		exit_button:
			exit_game()
		continue_button:
			continue_game()
	
## 打开菜单
func open() -> void:
	#button_container.get_child(0).grab_focus()
	get_parent().layer = 0
	InputManager.set_game_mode(InputManager.GameMode.OPEN_MODE)

func close() -> void:
	get_parent().layer = -1
	queue_free()
	InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)

## 保存游戏
func save_game() -> void:
	var data: Dictionary = {}
	## 保存全局数据
	data.set("global", Global.get_data())
	## 保存地图数据
	data.set("map", LevelManager.get_data())
	## 保存玩家数据
	data.set("player", Global.player.get_data())
	## 保存基础配置
	SaveSystem.save_game(data)
	tip_label.text = tr("ui_saving")
	await get_tree().create_timer(0.3).timeout
	tip_label.text = tr("ui_save_complete")
	await get_tree().create_timer(0.3).timeout
	tip_label.text = ""





## 退出游戏
func exit_game() -> void:
	get_tree().quit(0)


## 开始游戏
func start_game() -> void:
	LevelManager.clear()
	## 播放
	tip_label.text = tr("ui_world_creating")
	await get_tree().create_timer(0.3).timeout
	tip_label.text = ""
	Global.game_started = true
	Global.load_persist_data()
	SignalManager.start_game.emit(self)
	queue_free()



## 加载游戏
func load_game() -> void:
	LevelManager.clear()
	LevelManager.register_path(Global.world, Global.map_path)
	## 加载地图数据
	var data:Dictionary = SaveSystem.load_game()
	## 加载全局数据
	Global.load_persist_data()
	Global.set_data(data.get("global"))
	## 加载地图数据
	LevelManager.set_data(data.get("map"))
	## 加载玩家数据
	var start_player: Player = load("res://character/player/player.tscn").instantiate() as Player
	#var main: Node =  get_tree().root.get_node("/root/main")
	var player_creator: PlayerCreator = get_tree().root.get_node("/root/main/PlayerCreator")
	for child in player_creator.get_children():
		child.queue_free()
	player_creator.initialize(start_player)
	start_player.set_data(data.get("player"))
	
	Global.player = start_player
	player_creator.add_child(start_player)
	tip_label.text = tr("ui_world_loading")
	Global.game_started = true
	await get_tree().create_timer(0.3).timeout
	SignalManager.load_game.emit(self)
	tip_label.text = ""
	#load_button.hide()
	

func continue_game() -> void:
	InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)
	queue_free()

@onready var audio_setting: MarginContainer = %AudioSetting
@onready var language_button: Button = %LanguageButton
@onready var ending_achievement: MarginContainer = %EndingAchievement
@onready var ending_button: Button = %EndingButton
@onready var die_ending_label: Label = %DieEndingLabel
@onready var be_ending_label: Label = %BeEndingLabel
@onready var he_ending_label: Label = %HeEndingLabel
@onready var te_ending_label: Label = %TeEndingLabel
@onready var gd_ending_label: Label = %GdEndingLabel


func setting_game() -> void:
	audio_setting.show()
	_update_language_button_text()

func _update_language_button_text() -> void:
	if Global.language == "zh":
		language_button.text = tr("ui_lang_switch_to_en")
	else:
		language_button.text = tr("ui_lang_switch_to_zh")

@onready var audio_background_button: Button = %AudioBackgroundButton
@onready var audio_effect_button: Button = %AudioEffectButton

func _on_audio_background_button_pressed() -> void:
	#Global.can_play_audio_background != Global.can_play_audio_background
	if Global.can_play_audio_background:
		Global.can_play_audio_background = false
		audio_background_button.text = tr("ui_bgm_off")
	else:
		Global.can_play_audio_background = true
		audio_background_button.text = tr("ui_bgm_on")
	SignalManager.on_change_audio_background.emit(Global.current_background)
	audio_setting.hide()

func _on_audio_effect_button_pressed() -> void:
	if Global.can_play_audio_effect:
		audio_effect_button.text = tr("ui_sfx_off")
		Global.can_play_audio_effect = false
	else:
		Global.can_play_audio_effect = true
		audio_effect_button.text = tr("ui_sfx_on")
	SignalManager.on_change_audio_effect.emit()
	audio_setting.hide()

func _on_language_button_pressed() -> void:
	if Global.language == "zh":
		Global.set_language("en")
	else:
		Global.set_language("zh")
	_update_language_button_text()
	audio_setting.hide()

func _on_ending_button_pressed() -> void:
	_update_ending_display()
	audio_setting.hide()
	ending_achievement.show()

func _on_close_ending_button_pressed() -> void:
	ending_achievement.hide()

func _update_ending_display() -> void:
	var endings = {
		"die": {"label": die_ending_label, "key": "ending_die", "desc": "ending_die_desc"},
		"be": {"label": be_ending_label, "key": "ending_be", "desc": "ending_be_desc"},
		"he": {"label": he_ending_label, "key": "ending_he", "desc": "ending_he_desc"},
		"te": {"label": te_ending_label, "key": "ending_te", "desc": "ending_te_desc"},
		"gd": {"label": gd_ending_label, "key": "ending_gd", "desc": "ending_gd_desc"},
	}
	for code in endings:
		var e = endings[code]
		if Global.unlocked_endings[code]:
			e.label.text = tr(e.key) + "\n" + tr(e.desc)
		else:
			e.label.text = tr("ending_locked")
