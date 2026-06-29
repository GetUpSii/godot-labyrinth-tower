extends Character2d
class_name Pharmaceutist

@export var dialogue: DialogueResource
var craft_system: CraftSystem
var type: String = "pharmaceutist"
var shop: ShopUi
var player: Player

func _ready() -> void:
	add_to_group(&'npc')
	initialize()



## 使用的商店数据
var merchant_data: Array = [
	"healing_potion", "mana_potion", "red_herb", "blue_herb"
]
var potion_fee: Dictionary = {
	"defor_relieve_potion": {
		"gold": 150         # 需要150金币
	},
	"healing_potion": {
		"gold": 100         # 需要100金币
	},
	"perpetual_potion": {
		"gold": 300         # 需要300金币
	},
	"revealing_potion": {
		"gold": 100
	}
}

func get_data() -> Dictionary:
	var npc_data: Dictionary = {}
	npc_data.set("inventory", inventory.get_data())
	npc_data.set("position", global_position) 
	npc_data.set("character_name", character_name)
	return npc_data

func set_data(data: Dictionary) -> void:
	character_name = data.get("character_name")
	inventory.set_data(data["inventory"])
	global_position = data.get("position")

func initialize() -> void:
	instance = CharacterFactory.create_character("pharmaceutist")
	if inventory == null:
		inventory = InventorySyetem.new("药剂师")
		for id in merchant_data:
			var new_item: ItemInstance = ItemFactory.create_item(id, 5)
			inventory.add_item(new_item)
		inventory.gold = 500
	if craft_system == null:
		craft_system = CraftSystem.new()
		craft_system.user_name = character_name
		for key in potion_fee:
			var new_craft: CraftInstance = CraftFactory.create_craft(key)
			craft_system.add_craft(new_craft)

func on_player_interact(_player: Player) -> void:
	player = _player
	play_dialogue()
	be_friend()
	be_true_friend()
	#mowang_die()

#
#func mowang_die() -> void:
	#if !Global.npc_dict.has("finoa"):
		#return
	#if Global.get_die("finoa"):
		#if Global.get_dialogue_title("phar") == "true_friend":
			#Global.set_npc_dialogue_title("phar", "fiona_die2")
		#else:
			#Global.set_npc_dialogue_title("phar", "fiona_die")

func be_friend() ->void:
	if Global.npc_dict.get("phar").has("gold") and Global.get_dialogue_title("phar") == "ch1":
		var gold: int = Global.npc_dict.get("phar").get("gold")
		if gold >= 300:
			Global.set_npc_friend_with_player("phar", true)
			Global.set_npc_dialogue_title("phar", "friend")
			play_dialogue()

func be_true_friend() -> void:
	if Global.get_die("dog"):
		LogManager.add_entry(tr("log_became_friends") % instance.get_diplay_name())
		var dict_reward: Dictionary = {}
		dict_reward.set("gold", 200)
		dict_reward.set("exp",  600)	
		var ring: ItemInstance = ItemFactory.create_item("lover_ring")
		var potion: ItemInstance = ItemFactory.create_item("healing_potion", 3)
		dict_reward.set("item", [ring, potion])
		player.gain_reward(dict_reward)	
		player.craft_system.add_craft(CraftFactory.create_craft("healing_potion"))
		player.craft_system.add_craft(CraftFactory.create_craft("mana_potion"))
		Global.set_npc_dialogue_title("phar", "happy")
		play_dialogue()
		Global.set_npc_die("dog", false)
		#play_dialogue()
		return

func play_dialogue() -> void:
	DialogueManager.get_current_scene = func():
		return self
	SignalManager.play_dialogue_with.emit(dialogue, Global.get_dialogue_title("phar"))
	SignalManager.on_set_dialogue_texture.emit("yaojishi")

func reduce_gold(ptype: String) -> bool:
	var fee: int = potion_fee.get(ptype)["gold"]
	if player.inventory.gold < fee:
		return false
	else:
		return true

## 检查玩家inventory中的材料和钱满不满足,满足就制作药水放入玩家背包中
func check_bag(ptype: String) -> void:
	if !reduce_gold(ptype):
		return
	
	if craft_system.craft(player.inventory, ptype, "pot"):
		player.change_inventory("buy","", -potion_fee.get(ptype)["gold"]) 
		#player.change_inventory("buy",ptype)
		var consume_gold: int = Global.npc_dict.get("phar").get("gold") 
		consume_gold += potion_fee.get(ptype)["gold"]
		
		Global.npc_dict.get("phar").set("gold", consume_gold) 
		
		Global.check_consume()
		## 背包需要实时更新一下
		SignalManager.play_dialogue_with.emit(dialogue, "make_potion")
		
		return
	SignalManager.play_dialogue_with.emit(dialogue, "not_enough")

func battle_with_player() -> void:
	if player == null:
		push_error("player instance null")
		return
	if instance == null:
		push_error("no instance")
		return
	Global.set_npc_can_battle("dog", false)
	SignalManager.on_auto_battle_start.emit(player, self)
	SignalManager.on_auto_battle_finished.connect(on_auto_battle_finished)

func on_auto_battle_finished(_result) -> void:
	SignalManager.on_auto_battle_finished.disconnect(on_auto_battle_finished)
	if _result == BattleSystem.BATTLE_RESULT.PLAYER_WIN:
		_to_death()
	elif _result == BattleSystem.BATTLE_RESULT.PLAYER_LOSE:
		SignalManager.end_game.emit()	

func open_shop() -> void:
	SignalManager.on_npc_shop_open.emit(player, self)

func reward_item() -> Array[ItemInstance]:
	var rewards: Array[ItemInstance] = []
	for item in inventory.get_items():
		rewards.append(item)
	var ring: ItemInstance = ItemFactory.create_item("lover_ring")
	rewards.append(ring)
	return rewards

func _to_death() -> void:
	LogManager.add_entry(tr("log_has_died") % instance.get_diplay_name())
	LevelManager.current_level.remove_obstacle(self.global_position)
	var dict_reward: Dictionary = {}
	dict_reward.set("gold", 300)
	dict_reward.set("exp",  BattleSystem.calculate_reward_exp(player.instance, self.instance))
	dict_reward.set("item", reward_item())
	player.gain_reward(dict_reward)	
	Global.set_npc_die("phar", true)
	for key in potion_fee:
		var new_craft: CraftInstance = CraftFactory.create_craft(key)
		player.craft_system.add_craft(new_craft)
	player.craft_system.add_craft(CraftFactory.create_craft("mana_potion"))
	Global.set_npc_dialogue_title("phar", "die")
	play_dialogue()
	await DialogueManager.dialogue_ended
	##SignalManager.on_player_ui_update.emit(player)
	SignalManager.on_change_audio_effect.emit("applause")
	queue_free()
