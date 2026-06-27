extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var text_box: Control = $textBox
@onready var text_label: Label = $textBox/text

@export var text_lines: Array[String] = []

var text_index: int = 0


func _ready() -> void:
	text_box.visible = false

	area_2d.body_entered.connect(_on_area_2d_body_entered)
	area_2d.body_exited.connect(_on_area_2d_body_exited)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		show_text_box()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		text_box.visible = false


func show_text_box() -> void:
	text_box.visible = true

	if text_lines.is_empty():
		return

	var current_text := text_lines[text_index]
	text_label.text = current_text

	if current_text.contains("Peck the crown."):
		_on_rebel()

	if text_index < text_lines.size() - 1:
		text_index += 1

func _on_rebel() -> void:
	var player := get_tree().get_first_node_in_group("Player") as Node2D

	var popup := Label.new()
	popup.text = "Break the cage."
	popup.modulate.a = 1.0
	popup.z_index = 100

	player.add_child(popup)
	popup.position = Vector2(-40, -80)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup, "position:y", popup.position.y - 40.0, 1.2)
	tween.tween_property(popup, "modulate:a", 0.0, 1.2)

	await tween.finished
	popup.queue_free()
	
	var popupShiny := Label.new()
	popupShiny.text = "+2 Shiny"
	popupShiny.modulate.a = 1.0
	popupShiny.z_index = 100

	player.add_child(popupShiny)
	popupShiny.position = Vector2(-40, -80)

	var tweenShiny := create_tween()
	tweenShiny.set_parallel(true)
	tweenShiny.tween_property(popupShiny, "position:y", popupShiny.position.y - 40.0, 1.2)
	tweenShiny.tween_property(popupShiny, "modulate:a", 0.0, 1.2)
	GlobalSignalsManager.shinies +=2
	await tweenShiny.finished
	popupShiny.queue_free()
