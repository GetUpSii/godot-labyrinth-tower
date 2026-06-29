extends Character2d
@export var dialogue: DialogueResource
@export var type: String
var player: Player


var texture_change: bool = false


var task_dict: Dictionary = {
	"start": null
}





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
	check_bag()
	check_p_die()
	play_dialogue()

func check_p_die() -> void:
	if Global.get_die("phar"):
		Global.set_npc_dialogue_title("dog", "happy" )
		var dict_reward: Dictionary = {}
		dict_reward.set("gold", 1200)
		dict_reward.set("exp",  1000)
		player.gain_reward(dict_reward)
		texture_change = true
		await DialogueManager.dialogue_ended
		queue_free()
		return

func check_bag() -> void:
	if Global.player.check_inventory("defor_relieve_potion") :
		Global.player.change_inventory("reduce", "defor_relieve_potion")
		Global.set_npc_dialogue_title("dog", "have_potion") 
		Global.npc_dict.get("dog").set("have_potion", true)
		var dict_reward: Dictionary = {}
		dict_reward.set("gold", 200)
		dict_reward.set("exp",  200)
		dict_reward.set("item", [ItemFactory.create_item("dagger")])
		player.gain_reward(dict_reward)
		play_dialogue()
		return

func initialize() -> void:
	instance = CharacterFactory.create_character("dog")
	




func play_dialogue() -> void:
	DialogueManager.get_current_scene = func():
		return self
	SignalManager.play_dialogue_with.emit(dialogue, Global.get_dialogue_title("dog"))
	SignalManager.on_set_dialogue_texture.emit("dog")
	if texture_change:
		if Global.npc_dict.get("dog").get("have_potion"):
			SignalManager.on_set_dialogue_texture.emit("emo")


func battle_with_player() -> void:
	if player == null:
		push_error("player instance null")
		return
	if instance == null:
		push_error("no instance")
		return
	LogManager.add_entry(tr("log_entered_battle") % instance.get_diplay_name())
	## 如果拿到了变形药水，就会恢复成恶魔的真身
	if Global.npc_dict.get("dog").get("have_potion"):
		LogManager.add_entry(tr("log_recovered_form") % instance.get_diplay_name())
		instance = CharacterFactory.create_character("devil")	
		texture_change = true

	## 如果没有就是狗的属性版本
	Global.set_npc_can_battle("phar", false)
	SignalManager.on_auto_battle_start.emit(player, self)
	SignalManager.on_auto_battle_finished.connect(on_auto_battle_finished)


func on_auto_battle_finished(_result) -> void:
	SignalManager.on_auto_battle_finished.disconnect(on_auto_battle_finished)
	if _result == BattleSystem.BATTLE_RESULT.PLAYER_WIN:
		_to_death()
	elif _result == BattleSystem.BATTLE_RESULT.PLAYER_LOSE:
		SignalManager.end_game.emit()	


func reward_item() -> Dictionary:
	var dict_reward: Dictionary
	dict_reward.set("gold", 800)
	dict_reward.set("exp",  BattleSystem.calculate_reward_exp(player.instance, self.instance))
	dict_reward.set("item", [LootPool.get_loot("common"),])
	if Global.npc_dict.get("dog").get("have_potion"):
		dict_reward.set("item", [LootPool.get_loot("advance"),])
	return dict_reward


func _to_death() -> void:
	LogManager.add_entry(tr("log_has_died") % instance.get_diplay_name())
	LevelManager.current_level.remove_obstacle(self.global_position)
	var dict_reward: Dictionary = {}
	dict_reward = reward_item()
	
	player.gain_reward(dict_reward)	

	SignalManager.play_dialogue_with.emit(dialogue, "die")
	if Global.npc_dict.get("dog").get("have_potion"):
		SignalManager.on_set_dialogue_texture.emit("emo")
	else:
		SignalManager.on_set_dialogue_texture.emit("dog")
	await DialogueManager.dialogue_ended
	Global.set_npc_die("dog", true)
	SignalManager.on_change_audio_effect.emit("disapproval")
	##SignalManager.on_player_ui_update.emit(player)
	queue_free()
	pass
