extends Character2d
@export var dialogue: DialogueResource
@export var type: String
var player

var skills_dict: Dictionary = {
	"sorcerer": [
		"fireball",
		"burn",
	],
	"fiona":[
		"ice_gland",
		"frostcombo",
	]
}

func get_data() -> Dictionary:
	var npc_data: Dictionary = {}
	npc_data.set("position", global_position) 
	npc_data.set("character_name", character_name)
	return npc_data

func set_data(data: Dictionary) -> void:
	character_name = data.get("character_name")
	global_position = data.get("position")

func initialize() -> void:
	instance = CharacterFactory.create_character("fiona")
	if skill_system == null:
		skill_system = SkillSystem.new()
	for skill_key in skills_dict.get(type, []):
			var skill_instance: SkillInstance = SkillFactory.create_skill(skill_key)
			skill_system.add_skill(skill_instance)

func on_player_interact(_player: Player) -> void:
	player = _player
	play_dialogue()
	await  DialogueManager.dialogue_ended
	battle_with_player()


func play_dialogue() -> void:
	DialogueManager.get_current_scene = func():
		return self
	SignalManager.play_dialogue_with.emit(dialogue, Global.get_dialogue_title("fiona"))
	#SignalManager.on_set_dialogue_texture.emit("mowang")


func battle_with_player() -> void:
	if player == null:
		push_error("player instance null")
		return
	if instance == null:
		push_error("no instance")
		return
	SignalManager.on_battle_start.emit(player, self)
	#SignalManager.on_auto_battle_start.emit(player, self)
	if !SignalManager.on_auto_battle_finished.is_connected(on_fiona_battle_finished):
		SignalManager.on_auto_battle_finished.connect(on_fiona_battle_finished)

func on_fiona_battle_finished(_result) -> void:
	SignalManager.on_auto_battle_finished.disconnect(on_fiona_battle_finished)
	if _result == BattleSystem.BATTLE_RESULT.PLAYER_WIN:
		_to_death()
	elif _result == BattleSystem.BATTLE_RESULT.PLAYER_LOSE:
		SignalManager.end_game.emit("be")	
	elif _result == BattleSystem.BATTLE_RESULT.DEUCE:
		reward()
		InputManager.set_game_mode(InputManager.GameMode.WALK_MODE)
		queue_free()

func reward() -> void:
	var dict_reward: Dictionary = {}
	dict_reward.set("gold", 10000)
	dict_reward.set("exp",  BattleSystem.calculate_reward_exp(player.instance, self.instance))
	dict_reward.set("item", [ItemFactory.create_item("white_key")])
	player.gain_reward(dict_reward)	
	
func _to_death() -> void:
	
	LevelManager.current_level.remove_obstacle(self.global_position)
	reward()
	Global.set_npc_dialogue_title("fiona", "die")
	Global.set_npc_die("fiona", true)
	play_dialogue()
	await DialogueManager.dialogue_ended
	SignalManager.on_change_audio_effect.emit("applause")
	##SignalManager.on_player_ui_update.emit(player)
	queue_free()
