extends Character2d
class_name Enemy
@export var type: String
var player: Player

var skills_dict: Dictionary = {
	"sorcerer": [
		"fireball",
		"burn",
		
	],
	"bat2": [
		"suck_blood",
	],	
	
}
var dict_reward: Dictionary = {}

##attack_audio.play()
func get_data() -> Dictionary:
	if not instance:
		push_warning("敌人实例为空")
		return {}
	# 只保存差异数据
	var data: Dictionary = {}
	data.set("instance", instance.get_data())
	data.set("position", global_position)
	data.set("template_id", instance.get_template_id())
	return data


func set_data(data: Dictionary) -> void:
	instance = CharacterFactory.create_character(data["template_id"])
	instance.set_data(data.get("instance"))
	global_position = data.get("position")

func initialize() -> void:
	add_to_group("enemy")
	self.instance = CharacterFactory.create_character(type)
	skill_system = SkillSystem.new()
	for skill_key in skills_dict.get(type, []):
		var skill_instance: SkillInstance = SkillFactory.create_skill(skill_key)
		skill_system.add_skill(skill_instance)
	
	skill_sprite_2d.position.x = -skill_sprite_2d.position.x

func attack_player(_player: Player) -> void:
	if _player == null:
		push_error("player instance null")
		return
	if instance == null:
		push_error("no instance, reinitializing")
		initialize()
		if instance == null:
			return
	player = _player
	SignalManager.on_auto_battle_start.emit(_player, self)
	if !SignalManager.on_auto_battle_finished.is_connected(on_auto_battle_finished):
		SignalManager.on_auto_battle_finished.connect(on_auto_battle_finished)

func on_player_interact(_player: Player) -> void:
	## 当玩家选择挑战这个敌人时，会重复进行攻击直到curent_hp为0
#	print("遇到敌人，进行玩家的对战")
	if type == "sorcerer":
		if Global.last_end == "surrender":
			play_dialogue(type+ "_awake")
			await DialogueManager.dialogue_ended
			attack_player(_player)
			return
		play_dialogue(type)
		await DialogueManager.dialogue_ended
	attack_player(_player)



func play_dialogue(_title: String) -> void:
	DialogueManager.get_current_scene = func():
		return self
	SignalManager.play_dialogue_with.emit(load('res://resource/dialogue/enemy.dialogue'), _title)

func _to_death() -> void:
	
	LevelManager.current_level.remove_obstacle(self.global_position)
	
	dict_reward = BattleSystem.calculate_reward(player.instance, instance, "common")
	if instance.get_quality() == CharacterTemplate.Quality.INTERMEDIATE:
		dict_reward = BattleSystem.calculate_reward(player.instance, instance, "rare")
	if type == "sorcerer":
		var eternal_heart: ItemInstance = ItemFactory.create_item("eternal_heart")
		dict_reward.get("item").append(eternal_heart)
		if Global.last_end == "surrender":
			var momery_potion: ItemInstance = ItemFactory.create_item("memory_potion")
			dict_reward.get("item").append(momery_potion)
			Global.last_end = ""
			Global.save_persist_data()
		play_dialogue("die")
		await  DialogueManager.dialogue_ended
	player.gain_reward(dict_reward)	
	##SignalManager.on_player_ui_update.emit(player)
	LogManager.add_entry(tr("log_has_died") % instance.get_diplay_name())
	queue_free()
	pass
