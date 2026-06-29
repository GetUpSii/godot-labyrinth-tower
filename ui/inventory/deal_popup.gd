extends Control
class_name DealPopupBox
@onready var popup_panel: Window = %PopupPanel
@onready var input: LineEdit = %Input
var input_edit: int = 0
signal on_button_confimed_input

@onready var confirm: Button = %Confirm

func popupWindow():
	show()
	popup_panel.popup()
	
	
func hideWindow():
	hide()
	input.clear()
	popup_panel.hide()


func grab_edit() -> void:
	input.grab_focus()

func _on_confirm_pressed() -> void:
	on_button_confimed_input.emit(input_edit)
	hideWindow()
	##popupWindow()

func _on_cancel_pressed() -> void:
	hideWindow()


func _on_popup_panel_close_requested() -> void:
	hideWindow()
	pass # Replace with function body.

func returnInput() -> int:
	return input_edit

func _on_input_text_changed(new_text: String) -> void:
		## 限制输入
	if !new_text.is_valid_int() :
		if !new_text.is_empty():
			input.clear()
		return
	input_edit = str_to_var(new_text)
	pass # Replace with function body.
