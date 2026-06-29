extends Node

signal on_log_updated(new_entry)

var max_entries = 50  # 最大日志条目数
var entries = []      # 存储所有日志条目


# 添加新日志条目
func add_entry(text: String, _who: String = ""):
	var log_entry: String = ""
	if !_who.is_empty():
		log_entry = tr(_who) + " " + text
	else:
		log_entry = text
	entries.push_front(log_entry)  # 新条目添加到前面
	
	# 限制日志数量
	if entries.size() > max_entries:
		entries.pop_back()
	
	# 发出信号通知日志更新
	emit_signal("on_log_updated", log_entry)

func add_entries(arr: Array):
	for entry in arr:
		entries.push_front(entry)  # 新条目添加到前面
		emit_signal("on_log_updated", entry)



# 获取最近的N条日志
func get_recent_entries(count: int = 10) -> Array:
	return entries.slice(0, min(count, entries.size()) - 1)

# 清空日志
func clear_log():
	entries.clear()
	emit_signal("log_updated", null)
