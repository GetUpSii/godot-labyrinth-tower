extends CanvasLayer

## 手机触屏控制器
## 可见的虚拟摇杆 + 操作按钮
## 模拟键盘事件，让现有 GUIDE 输入系统无缝工作
##
## 工作方式：
## - 拖动虚拟摇杆 → 模拟 WASD 按键 → GUIDE 触发 move action → 玩家移动
## - 点击菜单按钮 → 模拟 Escape → 打开菜单
## - 点击背包按钮 → 模拟 I → 打开背包

## 触屏控制开关（桌面端自动隐藏）
@export var enabled: bool = true

## 连续移动：长按时是否持续移动
@export var enable_repeat: bool = true

## 重复移动间隔（秒）
@export var repeat_interval: float = 0.2

var _current_direction: Vector2 = Vector2.ZERO
var _last_key: int = -1
var _repeat_timer: float = 0.0

# 节点引用
@onready var joystick: VirtualJoystick = %VirtualJoystick
@onready var menu_button: Button = %MenuButton
@onready var bag_button: Button = %BagButton


func _ready() -> void:
	# 平台检测：非移动端隐藏触屏控制
	if not OS.has_feature("mobile") and not OS.has_feature("web"):
		hide()
		enabled = false
		set_process(false)
		return
	
	# 连接摇杆信号
	joystick.direction_changed.connect(_on_joystick_direction)
	joystick.activated.connect(_on_joystick_activated)
	joystick.deactivated.connect(_on_joystick_deactivated)
	
	# 连接按钮信号
	menu_button.pressed.connect(_on_menu_pressed)
	bag_button.pressed.connect(_on_bag_pressed)


func _process(delta: float) -> void:
	if not enabled or not enable_repeat:
		return
	
	# 长按摇杆时持续移动
	if _current_direction != Vector2.ZERO:
		_repeat_timer += delta
		if _repeat_timer >= repeat_interval:
			_repeat_timer = 0.0
			_simulate_key_press(_direction_to_key(_current_direction))


func _on_joystick_activated() -> void:
	_repeat_timer = 0.0


func _on_joystick_deactivated() -> void:
	_current_direction = Vector2.ZERO
	_last_key = -1
	_repeat_timer = 0.0


func _on_joystick_direction(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		_current_direction = Vector2.ZERO
		_last_key = -1
		return
	
	# 将摇杆方向映射到 4 个方向
	var snapped_dir: Vector2 = _snap_direction(dir)
	if snapped_dir == _current_direction:
		return  # 方向没变，不重复触发
	
	_current_direction = snapped_dir
	_repeat_timer = 0.0
	_simulate_key_press(_direction_to_key(_current_direction))


## 将任意方向映射到上下左右
func _snap_direction(dir: Vector2) -> Vector2:
	if dir.length() < 0.1:
		return Vector2.ZERO
	
	# 判断哪个轴更 dominant
	if abs(dir.x) > abs(dir.y):
		return Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	else:
		return Vector2.DOWN if dir.y > 0 else Vector2.UP


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


func _on_menu_pressed() -> void:
	var event = InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	Input.parse_input_event(event)
	event.pressed = false
	Input.parse_input_event(event)


func _on_bag_pressed() -> void:
	var event = InputEventKey.new()
	event.keycode = KEY_I
	event.pressed = true
	Input.parse_input_event(event)
	event.pressed = false
	Input.parse_input_event(event)
