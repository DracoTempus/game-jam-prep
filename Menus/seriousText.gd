extends Panel

signal advanced

@export var rich_text_label: RichTextLabel

var waiting_for_input := false


func _ready() -> void:
	hide()


func say(text: String) -> void:
	show()
	rich_text_label.text = text
	waiting_for_input = true

	await advanced

	waiting_for_input = false


func set_line(text: String) -> void:
	show()
	rich_text_label.text = text


func close() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if not waiting_for_input:
		return

	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		advanced.emit()
