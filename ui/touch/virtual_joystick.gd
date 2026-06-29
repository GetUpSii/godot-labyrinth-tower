extends Control
class_name VirtualJoystick

## 虚拟摇杆 - 可见的摇杆 UI
## 左侧滑动控制方向，带动画反馈

## 摇杆底座半径
@export var base_radius: float = 64.0
## 摇杆头半径
@export var thumb_radius: float = 24.0
## 死区（避免误触）
@export var deadzone: float = 12.0
## 摇杆透明度
@export var joystick_opacity: float = 0.35

## 当前方向（归一化向量）
var direction: Vector2 = Vector2.ZERO:
	set(value):
		direction = value
		direction_changed.emit(value)

## 方向变化信号
signal direction_changed(dir: Vector2)
## 激活信号
signal activated()
## 释放信号
signal deactivated()

var _touch_id: int = -1
var _is_active: bool = false
var _center: Vector2 = Vector2.ZERO
var _thumb_offset: Vector2 = Vector2.ZERO

# 绘制用
var _base_color: Color = Color(1, 1, 1, joystick_opacity)
var _thumb_color: Color = Color(1, 1, 1, joystick_opacity * 1.5)
var _active_color: Color = Color(0.5, 0.8, 1.0, 0.5)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_center = size / 2


func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	# 触摸/鼠标按下
	if event is InputEventScreenTouch and event.pressed:
		var local_pos = make_input_local(event).position
		if local_pos.distance_to(_center) <= base_radius:
			_touch_id = event.index
			_is_active = true
			_update_thumb(local_pos)
			activated.emit()
			queue_redraw()
		return
	
	# 触摸拖动
	if event is InputEventScreenDrag and event.index == _touch_id:
		var local_pos = make_input_local(event).position
		_update_thumb(local_pos)
		queue_redraw()
		return
	
	# 触摸释放
	if event is InputEventScreenTouch and not event.pressed and event.index == _touch_id:
		_reset()
		return


func _update_thumb(touch_pos: Vector2) -> void:
	var offset: Vector2 = touch_pos - _center
	var distance: float = offset.length()
	
	if distance <= deadzone:
		_thumb_offset = Vector2.ZERO
		direction = Vector2.ZERO
		return
	
	# 限制在底座范围内
	var max_distance: float = base_radius - thumb_radius
	if distance > max_distance:
		offset = offset.normalized() * max_distance
		distance = max_distance
	
	_thumb_offset = offset
	direction = offset / max_distance


func _reset() -> void:
	_touch_id = -1
	_is_active = false
	_thumb_offset = Vector2.ZERO
	direction = Vector2.ZERO
	deactivated.emit()
	queue_redraw()


func _draw() -> void:
	if not visible:
		return
	
	var center = size / 2
	
	# 绘制底座圆
	var base_color = _active_color if _is_active else _base_color
	draw_circle(center, base_radius, base_color)
	draw_arc(center, base_radius, 0, TAU, 64, Color(1, 1, 1, 0.2), 2.0)
	
	# 绘制十字参考线
	var line_len: float = base_radius * 0.3
	var line_color: Color = Color(1, 1, 1, 0.15)
	draw_line(center + Vector2(-line_len, 0), center + Vector2(line_len, 0), line_color, 1.0)
	draw_line(center + Vector2(0, -line_len), center + Vector2(0, line_len), line_color, 1.0)
	
	# 绘制摇杆头
	var thumb_pos: Vector2 = center + _thumb_offset
	var thumb_color = _active_color if _is_active else _thumb_color
	draw_circle(thumb_pos, thumb_radius, thumb_color)
	draw_circle(thumb_pos, thumb_radius, Color(1, 1, 1, 0.3), false, 2.0)
	
	# 方向指示
	if direction.length() > 0.1:
		var dir_end: Vector2 = center + direction * (base_radius + 12)
		var arrow_color: Color = Color(0.3, 0.8, 1.0, 0.6)
		draw_line(center, dir_end, arrow_color, 2.0)
		# 箭头尖端
		var arrow_size: float = 8.0
		var arrow_angle: float = direction.angle()
		var tip1 = dir_end + Vector2(arrow_size, 0).rotated(arrow_angle + 2.5)
		var tip2 = dir_end + Vector2(arrow_size, 0).rotated(arrow_angle - 2.5)
		draw_polygon([dir_end, tip1, tip2], [arrow_color])
