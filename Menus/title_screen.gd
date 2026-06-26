extends Control

@onready var start_button: Button = $StartButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var main := "res://Levels/Base/Base.tscn"
@export var enemy : PackedScene
@export var explosion : AnimatedSprite2D
@export var serious_panel: Panel

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	serious_panel.hide()

func _on_start_button_pressed() -> void:
	start_button.disabled = true

	await serious_panel.say("The first time I flew, every pigeon in the park stopped eating.'Wow. You are weird. That isn’t how a bird flies.'")
	await serious_panel.say("They were right. I didn’t glide. I didn’t flap.")
	await serious_panel.say("I hovered, wobbled, and chopped through the air like the human machine.")
	await serious_panel.say("So... the flock left me behind.")

	GlobalSignalsManager.goose_fly_speed = 500
	for i in range(30):
		var enemy_object = enemy.instantiate()
		enemy_object.global_position = Vector2(1000.0 + (25*i), -500+ (50.0 * i))
		add_child(enemy_object)
	await get_tree().create_timer(3).timeout
	
	for i in range(55):
		var explosion_object := explosion.duplicate() as AnimatedSprite2D
		explosion_object.visible = true
		explosion_object.global_position = Vector2(randf_range(100, 1000), randf_range(0, 700))
		add_child(explosion_object)

		explosion_object.play()

		explosion_object.animation_finished.connect(explosion_object.queue_free)
	await get_tree().create_timer(3).timeout
	
	await serious_panel.say("Then the geese attacked.")
	await serious_panel.say("Now 'day birds' are almost extinct, and only a few pigeon eggs remain")
	await serious_panel.say("The crows say they can make me stronger, if I bring them things worth trading.")
	await serious_panel.say("Crow magic is always a gamble")
	await serious_panel.say("Whether it’s soaring through the air, gambling with crows, or fighting with geese, the only way forward is to spin.")
	
	GlobalSignalsManager.goose_fly_speed = 90
	get_tree().change_scene_to_file(main)
