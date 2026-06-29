extends CharacterBody2D
class_name Character2d
var has_met: bool = false
## 角色名
@export var character_name: String = "";
@onready var sprite_2d: Sprite2D = $Animation/Sprite2D
@onready var skill_sprite_2d: Sprite2D = %SkillSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var instance: CharacterInstance
## 动画节点
@onready var sprite_2d_player: AnimationPlayer = $Animation/Sprite2DPlayer

@onready var animation: Node2D = $Animation
@onready var vfx_sprite_2d: Sprite2D = $Animation/VfxSprite2D


var inventory: InventorySyetem
var skill_system: SkillSystem
#@onready var hud = $"/root/LevelManager/HUD" as HUD
#
#@onready var _audio: Audio = $"/root/LevelManager/Audio"

func get_data() -> Dictionary:
	return {}


func set_data(_data: Dictionary) -> void:
	return

func play_animation_with(_type: String, dir_right: bool = false) -> void:
	match _type:
		"hurt": sprite_2d_player.play("hurt")
		"hit": sprite_2d_player.play("hit")
		"fireball": sprite_2d_player.play("skill_fireball")
		"suck_blood": sprite_2d_player.play("skill_suckblood")
		"potion": sprite_2d_player.play("skill_postion")
		"burn": sprite_2d_player.play("skill_fireball")
		"ice_gland": sprite_2d_player.play("skill_ice")
		"frostcombo": sprite_2d_player.play("skill_ice")
		_: push_error("there is no this animation")
	
func disable_collision(v: bool) -> void:
	collision_shape_2d.disabled = v

## 移动到指定位置
func move_to(pos: Vector2):
	var result = await self._on_move(pos)
	if result:
		self.position += pos
	return result

func on_auto_battle_finished(result) -> void:
	SignalManager.on_auto_battle_finished.disconnect(on_auto_battle_finished)
	if result == BattleSystem.BATTLE_RESULT.PLAYER_WIN:
		_to_death()
	elif result == BattleSystem.BATTLE_RESULT.PLAYER_LOSE:
		SignalManager.end_game.emit("die")	
## 攻击另一个角色

## 移动回调，返回false则不移动
func _on_move(_pos: Vector2):
	return true

## 死亡回调
func _to_death():
	pass
