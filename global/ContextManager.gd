# systems/ContextManager.gd
extends Node
class_name ContextManager

# 上下文优先级（数值越高优先级越高）
var context_priority = {
	"menu": 100,
	"ui": 80,
	"dialogue": 60,
	"player": 10
}

var active_contexts: Array[String] = []

func push_context(ctx: String):
	if ctx not in active_contexts:
		active_contexts.append(ctx)
		sort_contexts()

func pop_context(ctx: String):
	if ctx in active_contexts:
		active_contexts.erase(ctx)
		sort_contexts()

func get_current_context() -> String:
	if active_contexts.is_empty():
		return "player"
	return active_contexts[0]  # 最高优先级的上下文

func sort_contexts():
	active_contexts.sort_custom(func(a, b):
		return context_priority.get(b, 0) - context_priority.get(a, 0))
