extends Node

@export_group("Background Music")
@export var bg_music: AudioStream
@export var volume_db: float = -10.0
@export var autoplay_music: bool = true

@export_group("Startup UI")
@export var startup_panel: Control
@export var hide_input_action: String = "fly"

var panel_hidden_forever := false

func _ready() -> void:
	if bg_music != null:
		Musicplayer.play_music(bg_music, volume_db)
	if startup_panel != null:
		startup_panel.visible = true

func _process(_delta: float) -> void:
	if panel_hidden_forever:
		return

	if startup_panel == null:
		return

	if Input.is_action_just_pressed(hide_input_action):
		panel_hidden_forever = true
		startup_panel.queue_free()
		startup_panel = null
