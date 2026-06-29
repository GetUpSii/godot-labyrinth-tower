extends RichTextLabel
@export_multiline var prompt: String = ""
@export var actions: Array[GUIDEAction] = []
var _formatter: GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts()

func _ready() -> void:
	GUIDE.input_mappings_changed.connect(_update_label)
	_update_label()
	
func _update_label() -> void:
	## 初始化标签
	var actions_as_richtext: Array[String] = []
	actions_as_richtext.resize(actions.size())
	
	for i in actions:
		actions_as_richtext[i] = await _formatter.action_as_richtext_async(actions[i])
	#text = await _formatter.action_as_richtext_async(action)
	text = prompt % actions_as_richtext
	
