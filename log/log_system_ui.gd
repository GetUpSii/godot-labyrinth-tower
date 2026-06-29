extends Control

@onready var rich_text_label: RichTextLabel = $PanelContainer/RichTextLabel
var count: int = 0

var max_count: int = 80
func _ready() -> void:
	LogManager.on_log_updated.connect(_on_log_updated)


func _on_log_updated(text: String) -> void:
	if count > max_count:
		rich_text_label.clear()
		count = 0
	rich_text_label.add_text(text + "\n")
	count += 1
	# 在下一帧将滚动条移动到底部
#	call_deferred("_scroll_to_bottom")

#func _scroll_to_bottom():
	## 获取ScrollContainer的垂直滚动条
	#var vscroll = scroll_container.get_v_scroll_bar()
	#
	## 将滚动条位置设置为最大值
	#vscroll.value = vscroll.max_value
