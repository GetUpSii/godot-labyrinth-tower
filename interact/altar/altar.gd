extends StaticBody2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var dialogue: DialogueResource
var player: Player

var buffers = {
	"riches" : {"type": "modify_stat", "mod_type": "flat", "stat": "attack", "value": 1, "duration": 0
		},
		
	"item":
		{"type": "modify_stat", "mod_type": "flat", "stat": "defense", "value": 10, "duration": 0}
		
}

func set_buff(title: String) -> void:
	var user: CharacterInstance = player.instance
	var id: String = "altar_" + title + ItemInstance.generate_unique_id()
	#Global.buffer_id.set("altar", id)
	if title == "riches":
		buffers.get(title).set("unique_id", id)
		EffectExecutor.apply_single_effect_dict(buffers.get(title), user)
		user.current_hp += 50
	if title == "item":
		buffers.get(title).set("unique_id", id)
		EffectExecutor.apply_single_effect_dict(buffers.get(title), user)
	SignalManager.on_player_ui_update.emit(player)


func chose(v: String) -> void:
	if v == "riches":
		## 检查背包
		if player.inventory.gold >= 500:
			player.change_inventory("buy", "", -500)
			## 为玩家增加能力值
			set_buff(v)
		else:
			LogManager.add_entry(tr("shop_gold_insufficient"))
	elif v == "item":
		if player.inventory.get_item_by_template("lover_ring"):
			if player.change_inventory("reduce", "lover_ring"):
			## 为玩家增加能力值
				set_buff(v)
		else:
			LogManager.add_entry(tr("log_not_enough_items"))


func on_player_interact(_player: Player) -> void:
	## 检查玩家身上的库存，如果有钥匙的话就打开	print("拾取")
	## 进行祭坛对话
	player = _player
	DialogueManager.get_current_scene = func():
		return self
	SignalManager.play_dialogue_with.emit(dialogue, "start")
