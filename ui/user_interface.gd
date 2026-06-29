extends CanvasLayer


@onready var game_ui: Control = $GameUi

@export var switch_to_open: GUIDEAction
@export var switch_to_walk: GUIDEAction
@export var bag_switch_to_walk: GUIDEAction
@export var walk_switch_to_bag: GUIDEAction

var battle_ui: BattleUi
var main_menu: MainMenu
var inventory_ui: InventoryUi
var skill_ui: SkillUi
var shop_ui: ShopUi
var craft: CraftUi
func _ready() -> void:
	_switch_open_menu()
	SignalManager.start_game.connect(_on_start_game)
	SignalManager.load_game.connect(_on_load_game)
	
	game_ui.button_pressed.connect(_on_game_ui_button_pressed)

	SignalManager.on_npc_shop_open.connect(_on_npc_shop_open)
	SignalManager.on_auto_battle_start.connect(_on_auto_battle_start)
	SignalManager.on_auto_battle_finished.connect(_on_auto_battle_finished)
	SignalManager.on_battle_start.connect(_on_battle_start)
	switch_to_open.triggered.connect(_switch_open_menu)
	switch_to_walk.triggered.connect(_switch_close_menu)
	bag_switch_to_walk.triggered.connect(_switch_close_bag)
	walk_switch_to_bag.triggered.connect(_switch_open_bag)
	SignalManager.on_craft_at_plot.connect(_on_craft_at_plot)
	
func _on_game_ui_button_pressed(_type) -> void:
	match _type:
		"bag":_on_bag_pressed()
		"skill":_on_skill_pressed()
		"craft": _on_craft_pressed()
		"setting": _on_setting_pressed()
		"equipment": pass
		_:push_error("there is no this type can handle")



func _switch_open_menu() -> void:
	if main_menu == null:
		main_menu = load(Global.ui_scenes.get("main_menu")).instantiate() as MainMenu
		#main_menu.grab()
		add_child(main_menu)
	main_menu.open()
	

func _switch_close_menu() -> void:
	if main_menu:
		main_menu.close()



func _switch_open_craft(_tool: String = "hand") -> void:
	if craft == null:
		craft = load(Global.ui_scenes.get("craft")).instantiate() as CraftUi
		add_child(craft)
	craft.open(Global.player.craft_system, _tool)
	

func _switch_close_craft() -> void:
	if craft:
		craft.close()




func _switch_open_skill() -> void:
	if skill_ui == null:
		skill_ui = load(Global.ui_scenes.get("skill")).instantiate() as SkillUi
		add_child(skill_ui)
	skill_ui.open(Global.player.skill_system)


func _switch_close_skill() -> void:
	if skill_ui:
		skill_ui.close()

func _switch_open_bag() -> void:
	if inventory_ui == null:
		inventory_ui = load(Global.ui_scenes.get("bag")).instantiate() as InventoryUi
		add_child(inventory_ui)
	inventory_ui.open(Global.player.inventory)


func _switch_close_bag() -> void:
	if inventory_ui:
		inventory_ui.close()


func _on_start_game(menu: Control) -> void:
	menu.queue_free()
	_switch_close_menu()
	InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)

func _on_load_game(menu: Control) -> void:
	menu.queue_free()
	_switch_close_menu()
	InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)



func _on_npc_shop_open(_player: Player, merchant: Character2d) -> void:
	
	shop_ui = load(Global.ui_scenes.get("shop")).instantiate() as ShopUi
	
	add_child(shop_ui)
	shop_ui.initialize(_player, merchant)
	layer = 0
	shop_ui.on_shop_closed.connect(_on_shop_closed)
	InputManager.set_game_mode(InputManager.GameMode.DIALOGIC_MODE)

func _on_shop_closed(sum: int) -> void:
	layer = -1
	var total: int = Global.npc_dict.get("phar").get("gold") 
	total += sum
	Global.npc_dict.get("phar").set("gold", total)
	#shop_ui.close()
	#Global.input_manager.set_game_mode(InputManager.GameMode.WALK_MODE)


func _on_skill_pressed() -> void:
	_switch_open_skill()



func _on_craft_pressed() -> void:
	_switch_open_craft()


func _on_craft_at_plot(_tool: String) -> void:
	_switch_open_craft(_tool)





func _on_bag_pressed() -> void:
	_switch_open_bag()


func _on_setting_pressed() -> void:
	_switch_open_menu()

#func _input(event: InputEvent) -> void:
	##if event.is_action_pressed(&'open_menu'):
		##main_menu.open()
	#if event.is_action_pressed(&'open_bag'):
		#if !Global.player:
			#return
		#inventory_ui.open(Global.player.inventory)

## 自动战斗开始
func _on_auto_battle_start(_player: Player, _enemy: Character2d) -> void:
	if battle_ui == null:
		battle_ui = load(Global.ui_scenes.get("battle")).instantiate() as BattleUi 
		add_child(battle_ui)
		battle_ui.set_characters(_player, _enemy)
		layer = 0
		SignalManager.on_change_audio_background.emit("battle")
		InputManager.set_game_mode(InputManager.GameMode.DIALOGIC_MODE)

func _on_auto_battle_finished(_result) -> void:
	if battle_ui:
		battle_ui.queue_free()
		layer = -1
		SignalManager.on_change_audio_background.emit("default")
		
		
func _on_battle_start(_player: Player, _enemy: Character2d) -> void:
	if battle_ui == null:
		battle_ui = load(Global.ui_scenes.get("battle")).instantiate() as BattleUi 
		add_child(battle_ui)
		battle_ui.set_characters(_player, _enemy, false)
		layer = 0
		SignalManager.on_change_audio_background.emit("battle")
		InputManager.set_game_mode(InputManager.GameMode.DIALOGIC_MODE)
