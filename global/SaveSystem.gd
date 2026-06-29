extends Node



# 保存实现
func save_game(data: Dictionary):
	var file = FileAccess.open("user://save.bin", FileAccess.WRITE)
	file.store_var({
		"header": "MYSAVE",
		"version": 0.1,
		"data": data
	})
	file.close()

# 读取实现
func load_game():
	var file = FileAccess.open("user://save.bin", FileAccess.READ)
	if file and file.get_length() > 0:
		var save_data: Dictionary = file.get_var()
		if save_data["header"] == "MYSAVE":
			return save_data["data"]
	return null












## 1. 批量处理提高效率
#var save_queue = []
#func add_to_save_queue(data):
	#save_queue.append(data)
	#if save_queue.size() > 10:
		#save_batch()
#
## 2. 增量保存避免全量写入
#func save_incremental_changes():
	#var changes = get_unsaved_changes()
	#FileAccess.open("user://changes.bin", FileAccess.WRITE_APPEND)
	## 仅追加变化部分
#
## 3. 使用二进制压缩
#func compress_data(data: Dictionary) -> PackedByteArray:
	#var json = JSON.stringify(data)
	#return json.to_utf8_buffer().compress(FileAccess.COMPRESSION_ZSTD)
