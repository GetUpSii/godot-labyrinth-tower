class_name CharacterInstance

# 实例属性
var template: CharacterTemplate    # 关联的模板
var current_hp: int
var current_mp: int
var level: int = 1
var exp: int = 0
var unique_id: String = ""              # 实例唯一ID

# 信号
#signal on_character_skill_cooldown
signal on_character_ui_update
signal on_character_equipment_equip_unquip
# 添加属性修改器系统
var modifier_system: StatModifierSystem = StatModifierSystem.new(["attack", "defense", "max_hp", "max_mp"])


# 物品栏 [unique_id: ItemInstance]
#var inventory: Dictionary = {}

# 装备栏 [EquipmentSlot: EquipmentInstance]
var equipment: Dictionary = {}

# 技能
var skills: Dictionary = {}


var buff: Array = []

## 创建的时候套用模板，初始化
func _init(p_template: CharacterTemplate):
	template = p_template
	# 初始化修改属性

	equipment = {
		"head": "",
		"body": "",
		"hands": "",
		"feet": "",
		"finger": ""
	}
	unique_id = generate_unique_id()
	## 强制参数用 _init()，可选参数用默认值
	current_hp = calculate_max_hp()
	current_mp = calculate_max_mp()
	debug_print()

# character_instance.gd 新增内容
func get_template_id() -> String:
	return template.id

func get_quality() -> CharacterTemplate.Quality:
	return template.quality


func get_type() -> String:
	return template.id

func get_diplay_name() -> String:
	return template.display_name


func get_damage(v: int) -> void:
	current_hp -= v
	on_character_ui_update.emit("current_hp")


func get_data() -> Dictionary:
	var data: Dictionary = {}
	data.set("template_id", template.id)
	data.set("current_hp", current_hp)
	data.set("current_mp", current_mp)
	data.set("level", level)
	data.set("exp", exp)
	data.set("unique_id", unique_id)
	data.set("buff", buff)
	return data

# 只保存差异数据，不需要保存模板数据
func set_data(data: Dictionary) -> void:
	#id = data.get("template_id", null)
	current_hp = data.get("current_hp", calculate_max_hp())
	current_mp = data.get("current_mp", calculate_max_mp())
	level = data.get("level", 1)
	exp = data.get("exp", 0)
	unique_id = data.get("unique_id", null)
	load_buffer(data.get("buff", []))
	

func load_buffer(data: Array) -> void:
	if !data.is_empty():
		var effects: Array
		for effect in data:
			effects.append(EffectDescriptor.create_from_config(effect))
		EffectExecutor.apply_effects(effects, self)



# 生成唯一ID\
static func generate_unique_id() -> String:
	var uuid := "%s_%s" % [
		str(randi() % 1000).pad_zeros(3),
		str(Time.get_ticks_msec())  # 毫秒级时间戳
	]
	return uuid
	#return "char_%s" % str(OS.get_unix_time()) + str(randi() % 10000)

# 计算当前等级最大HP
func calculate_max_hp() -> int:
	return int(template.base_hp + (template.base_hp * 0.1 * (level - 1))) ##+ modified_stats["max_hp"])

# 计算当前等级最大MP
func calculate_max_mp() -> int:
	return int(template.base_mp + (template.base_mp * 0.1 * (level - 1)) )##+ modified_stats["max_mp"]

func get_current_hp() -> int:
	return current_hp

func get_current_mp() -> int:
	return current_mp

# 获取当前攻击力（包括加成）
func get_attack() -> int:
	var base = template.base_attack + (template.base_attack * 0.1 * (level - 1))
	return base + modifier_system.get_final_value("attack")

# 获取当前防御力（包括加成）
func get_defense() -> int:
	var base = template.base_defense + (template.base_defense * 0.1 * (level - 1))
	return base + modifier_system.get_final_value("defense")

func get_exp_to_next_level() -> int:
	# 简单的线性或指数模型（可扩展为查表）
	return 300 + int(pow(level, 1.5) * 10)

func release_magic(mana: int) -> bool:
	var value = current_mp
	if (value-mana) < 0:
		return false
	else:
		current_mp -= mana
		on_character_ui_update.emit("current_mp")
		return true


## 获取经验
func gain_exp(amount: int) -> void:
	exp += amount
	while exp >= get_exp_to_next_level():
		exp -= get_exp_to_next_level()
		level += 1
		var text: String = "%s升级到了等级%d!" % [template.display_name, level]
		print(text)
		LogManager.add_entry(text)
		

	## 魔塔中不对最大生命值进行限制
	#	current_hp = calculate_max_hp()
	#	current_mp = calculate_max_mp()



func handle_equipped(_slot: String, _id) -> bool:
	if !equipment.has(_slot):
		print("there is no this slot in character")
		return false
	var equipped_id: String = equipment.get(_slot)
	if equipped_id.is_empty():
		equipment.set(_slot, _id)
		return true
	else:
		if unequip_on_slot(_slot):
			on_character_equipment_equip_unquip.emit(equipped_id, false)
			
			return false
	return true
		#equipment.get(_slot).unequip()

func equip_on_slot(_slot: String, _id: String) -> void:
	equipment[_slot] = _id

func unequip_on_slot(_slot: String) -> bool:
	if equipment.has(_slot):
		var equipped_id: String = equipment.get(_slot)
		if equipped_id.is_empty() || equipped_id == null:
			push_error("there is no this id in equipment")
			return false
		equipment.set(_slot, "")
		return true
	return false

## 装备相关
func get_equipped_slot(_slot):
	return equipment.find_key(_slot)


func heal_hp(v: int) -> void:
	current_hp += v

func heal_mp(v: int) -> void:
	current_mp += v

func debug_print() -> void:
	print("create unique id: %s, display name: %s, hp: %d, mp: %d" % [unique_id, template.display_name, current_hp, current_mp])
