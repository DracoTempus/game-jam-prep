extends Control

@onready var start_button: Button = $StartButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var main := "res://Levels/Base/Base.tscn"
@export var enemy : PackedScene
@export var explosion : AnimatedSprite2D
@export var serious_panel: Panel
@export var bird_container: Node2D
@export var fade_out: ColorRect
@export var intro: Label

@export var music: AudioStream
@export var bad_music: AudioStream
@export var volume_db: float = 0.0
@export var autoplay: bool = true
@export var loop: bool = true

var music_player: AudioStreamPlayer

func _ready() -> void:
	intro.modulate.a = 0.0
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	if music is AudioStreamOggVorbis:
		music.loop = loop

	music_player.stream = music
	music_player.volume_db = volume_db

	if autoplay and music != null:
		music_player.play()
	
	start_button.pressed.connect(_on_start_button_pressed)
	serious_panel.hide()
	fade_out.modulate.a = 0.0
	fade_out.visible = true

func _on_start_button_pressed() -> void:
	start_button.disabled = true

	await serious_panel.say("The first time I flew, every pigeon in the park stopped eating.'Wow. You are weird. That isn’t how a bird flies.'")
	await serious_panel.say("They were right. I didn’t glide. I didn’t flap.")
	await serious_panel.say("I hovered, wobbled, and chopped through the air like the human machine.")
	music_player.stop()
	await serious_panel.say("So... the flock left me behind.")
	serious_panel.modulate.a = 0.0
	music_player.stream = bad_music
	GlobalSignalsManager.goose_fly_speed = 500
	for i in range(30):
		var enemy_object = enemy.instantiate()
		enemy_object.global_position = Vector2(1000.0 + (25*i), -500+ (50.0 * i))
		add_child(enemy_object)
		
	music_player.play(30)
	await get_tree().create_timer(3).timeout
	
	for i in range(55):
		var explosion_object := explosion.duplicate() as AnimatedSprite2D
		explosion_object.visible = true
		explosion_object.global_position = Vector2(randf_range(100, 1000), randf_range(0, 700))
		add_child(explosion_object)

		explosion_object.play()

		explosion_object.animation_finished.connect(explosion_object.queue_free)
		
	fade_out.visible = true
	fade_out.modulate.a = 0.0

	var fade_out_tween := create_tween()
	fade_out_tween.tween_property(fade_out, "modulate:a", 1.0, 1.5)
	
	for child in bird_container.get_children():
		child.queue_free()
	
	await get_tree().create_timer(3).timeout
	
	serious_panel.modulate.a = 1.0
	await serious_panel.say("Then the geese attacked.")
	await serious_panel.say("Now 'day birds' are almost extinct, and only a few pigeon eggs remain")
	await serious_panel.say("The crows say they can make me stronger, if I bring them things worth trading.")
	await serious_panel.say("Crow magic is always a gamble")
	await serious_panel.say("Whether it’s soaring through the air, gambling with crows, or fighting with geese, the only way forward is to spin.")
	serious_panel.modulate.a = 0.0
	intro.visible = true

	var intro_tween := create_tween()
	intro_tween.tween_property(intro, "modulate:a", 1.0, 1.2)

	await get_tree().create_timer(3).timeout
	GlobalSignalsManager.goose_fly_speed = 90
	get_tree().change_scene_to_file(main)
