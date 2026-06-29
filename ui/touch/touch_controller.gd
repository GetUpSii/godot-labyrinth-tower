extends CanvasLayer

## 手机触屏控制器
## 检测触摸手势，模拟键盘事件，让现有 GUIDE 输入系统无缝工作
##
## 工作方式：
## - 滑动屏幕 → 模拟 WASD 按键 → GUIDE 触发 move action → 玩家移动
## - 点击菜单按钮 → 模拟 Escape → 打开菜单
## - 点击背包按钮 → 模拟 I → 打开背包

## 触屏控制开关（桌面端自动隐藏）
@export var enabled: bool = true

## 滑动触发阈值（像素）
@export var swipe_threshold: float = 30.0

## 连续移动：长按时是否持续移动
@export var enable_repeat: bool = true

## 重复移动间隔（秒）
@export var repeat_interval: float = 0.2

# 触摸状态
var _touch_id: int = -1
var _touch_start: Vector2 = Vector2.ZERO
var _touch_current: Vector2 = Vector2.ZERO
var _current_direction: Vector2 = Vector2.ZERO
var _is_touching: bool = false
var _repeat_timer: float = 0.0
var _has_moved: bool = false

# 按钮引用
@onready var menu_button: Button = %MenuButton
@onready var bag_button: Button = %BagButton
@onready var touch_area: Control = %TouchArea

func _ready() -> void:
	# 平台检测：非移动端隐藏触屏控制
	if not OS.has_feature("mobile") and not OS.has_feature("web"):
		hide()
		enabled = false
		set_process(false)
		set_process_input(false)
		return
	
	# 连接按钮信号
	menu_button.pressed.connect(_on_menu_pressed)
	bag_button.pressed.connect(_on_bag_pressed)


func _input(event: InputEvent) -> void:
	if not enabled:
		return
	
	# 触摸开始
	if event is InputEventScreenTouch and event.pressed:
		_touch_id = event.index
		_touch_start = event.position
		_touch_current = event.position
		_is_touching = true
		_current_direction = Vector2.ZERO
		_has_moved = false
		_repeat_timer = 0.0
		
		# 点按（非滑动）触发交互
		_release_all_keys()
		return
	
	# 触摸结束
	if event is InputEventScreenTouch and not event.pressed and event.index == _touch_id:
		_is_touching = false
		_release_all_keys()
		_touch_id = -1
		_current_direction = Vector2.ZERO
		return
	
	# 触摸拖动（滑动）
	if event is InputEventScreenDrag and event.index == _touch_id:
		_touch_current = event.position
		var delta: Vector2 = _touch_current - _touch_start
		
		if delta.length() >= swipe_threshold and not _has_moved:
			_has_moved = true
			# 确定滑动方向
			if abs(delta.x) > abs(delta.y):
				_current_direction = Vector2.RIGHT if delta.x > 0 else Vector2.LEFT
			else:
				_current_direction = Vector2.DOWN if delta.y > 0 else Vector2.UP
			
			# 模拟按键 + 立即释放（触发 Pulse 一次）
			_simulate_key_press(_direction_to_key(_current_direction))


func _process(delta: float) -> void:
	if not enabled or not _is_touching or not enable_repeat:
		return
	
	# 连续移动：长按时持续触发
	if _has_moved:
		_repeat_timer += delta
		if _repeat_timer >= repeat_interval:
			_repeat_timer = 0.0
			_simulate_key_press(_direction_to_key(_current_direction))


func _direction_to_key(dir: Vector2) -> int:
	match dir:
		Vector2.UP:
			return KEY_W
		Vector2.DOWN:
			return KEY_S
		Vector2.LEFT:
			return KEY_A
		Vector2.RIGHT:
			return KEY_D
	return -1


func _simulate_key_press(keycode: int) -> void:
	if keycode < 0:
		return
	
	# 按下
	var press_event = InputEventKey.new()
	press_event.keycode = keycode
	press_event.pressed = true
	Input.parse_input_event(press_event)
	
	# 释放（同一帧释放 = Pulse 触发一次）
	var release_event = InputEventKey.new()
	release_event.keycode = keycode
	release_event.pressed = false
	Input.parse_input_event(release_event)


func _release_all_keys() -> void:
	for key in [KEY_W, KEY_A, KEY_S, KEY_D, KEY_ESCAPE, KEY_I]:
		var event = InputEventKey.new()
		event.keycode = key
		event.pressed = false
		Input.parse_input_event(event)


func _on_menu_pressed() -> void:
	_simulate_key_press(KEY_ESCAPE)


func _on_bag_pressed() -> void:
	_simulate_key_press(KEY_I)
