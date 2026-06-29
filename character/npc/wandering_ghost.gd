extends Character2d
@export var dialogue: DialogueResource
@export var type: String
var player: Player
var result: BattleSystem.BATTLE_RESULT

func _ready() -> void:
	add_to_group(&'npc')

func get_data() -> Dictionary:
	var npc_data: Dictionary = {}
	npc_data.set("position", global_position) 
	npc_data.set("character_name", character_name)
	return npc_data

func set_data(data: Dictionary) -> void:
	character_name = data.get("character_name")
	global_position = data.get("position")


func on_player_interact(_player: Player) -> void:
	player = _player
	check_bag_memory_potion()
	check_bag_bones()
	play_dialogue()
	SignalManager.on_set_dialogue_texture.emit("ghost")
	if Global.get_dialogue_title("wandering_ghost") == "insane":
		await DialogueManager.dialogue_ended
		battle_with_player()

func check_bag_bones() -> void:
	if Global.get_dialogue_title("wandering_ghost") == "find_memory":
		if Global.player.check_inventory("bones"): 
			LogManager.add_entry(tr("log_ghost_got_bones"))
			LogManager.add_entry(tr("log_ghost_recovered_memory"))
			Global.player.change_inventory("reduce", "bones")
			var dict_reward: Dictionary = {}
			dict_reward.set("exp",  800)
			dict_reward.set("item", reward_item())	
			player.gain_reward(dict_reward)
			Global.memory += 1
			Global.set_npc_dialogue_title("wandering_ghost", "bones")
		
		else:
			LogManager.add_entry(tr("log_ghost_went_insane"))
			Global.set_npc_dialogue_title("wandering_ghost", "insane")	


func check_bag_memory_potion() -> void:
	var dict_reward: Dictionary = {}
	if Global.player.check_inventory("memory_potion") and Global.get_dialogue_title("wandering_ghost") == "start":
		LogManager.add_entry(tr("log_ghost_got_potion"))
		Global.player.change_inventory("reduce", "memory_potion")
		
		Global.set_npc_dialogue_title("wandering_ghost", "find_memory")
		#dict_reward.set("gold", 1000)
		dict_reward.set("exp",  1500)
#		dict_reward.set("item", [ItemFactory.create_item("")])
		player.gain_reward(dict_reward)
		return
	

func initialize() -> void:
	instance = CharacterFactory.create_character("wandering_ghost")
	if skill_system == null:
		skill_system = SkillSystem.new()	
		
func play_dialogue() -> void:
	DialogueManager.get_current_scene = func():
		return self
	SignalManager.play_dialogue_with.emit(dialogue, Global.get_dialogue_title("wandering_ghost"))
	#DialogueManager.show_example_dialogue_balloon(dialogue,"start")
	SignalManager.on_set_dialogue_texture.emit("ghost")
	##disable_collision(true)


func battle_with_player() -> void:
	if player == null:
		push_error("player instance null")
		return
	if instance == null:
		push_error("no instance")
		return
	SignalManager.on_auto_battle_start.emit(player, self)
	if !SignalManager.on_auto_battle_finished.is_connected(on_auto_battle_finished):
		SignalManager.on_auto_battle_finished.connect(on_auto_battle_finished)


func on_auto_battle_finished(_result) -> void:
	SignalManager.on_auto_battle_finished.disconnect(on_auto_battle_finished)
	if _result == BattleSystem.BATTLE_RESULT.PLAYER_WIN:
		_to_death()
	elif _result == BattleSystem.BATTLE_RESULT.PLAYER_LOSE:
		SignalManager.end_game.emit("die")	


func reward_item() -> Array[ItemInstance]:
	var rewards: Array[ItemInstance] = []
	#var heart: ItemInstance = ItemFactory.create_item("eternal_heart")
	var helmet: ItemInstance = ItemFactory.create_item("leather_helmet")
	var note: ItemInstance = ItemFactory.create_item("veteran_note1")
	rewards.append(helmet)
	rewards.append(note)
	return rewards


func _to_death() -> void:
	LogManager.add_entry(tr("log_has_died") % instance.get_diplay_name())
	LevelManager.current_level.remove_obstacle(self.global_position)
	var dict_reward: Dictionary = {}
	dict_reward = BattleSystem.calculate_reward(player.instance, instance, "rare")
	dict_reward.get("item").append_array(reward_item())
	player.gain_reward(dict_reward)	
	Global.set_npc_dialogue_title("wandering_ghost", "die")
	play_dialogue()
	await  DialogueManager.dialogue_ended
	queue_free()
	pass
