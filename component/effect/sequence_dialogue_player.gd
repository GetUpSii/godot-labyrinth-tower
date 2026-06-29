extends Node

## 依次播放对话列表
## 用法:
##   SequenceDialoguePlayer.play_sequence([
##       [dialogue_res, "memory1"],
##       [dialogue_res, "memory2"],
##   ])

var _queue: Array = []
var _is_playing: bool = false

func play_sequence(sequence: Array) -> void:
	if sequence.is_empty():
		return
	_queue = sequence.duplicate()
	if not _is_playing:
		_is_playing = true
		_play_next()

func _play_next() -> void:
	if _queue.is_empty():
		_is_playing = false
		return
	
	var item = _queue.pop_front()
	var dialogue = item[0] if item.size() > 0 else null
	var title = item[1] if item.size() > 1 else ""
	
	# 播放当前对话
	SignalManager.play_dialogue_with.emit(dialogue, title)
	
	# 等待对话结束后再播放下一个
	await DialogueManager.dialogue_ended
	# 等一帧确保UI完全清理（如果节点还在场景树中）
	if is_inside_tree():
		await get_tree().process_frame
	_play_next()
