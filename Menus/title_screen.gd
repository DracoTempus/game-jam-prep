extends Control

@onready var start_button: Button = $StartButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var main := "res://Levels/Base/Base.tscn"
@export var enemy : PackedScene
@export var explosion : AnimatedSprite2D

func _ready() -> void:
	start_button.pressed.connect(_on_start_button_pressed)


func _on_start_button_pressed() -> void:
	start_button.disabled = true

	GlobalSignalsManager.goose_fly_speed = 500
	for i in range(30):
		var enemy_object = enemy.instantiate()
		enemy_object.global_position = Vector2(1000.0 + (25*i), -500+ (50.0 * i))
		add_child(enemy_object)
	await get_tree().create_timer(3).timeout
	for i in range(25):
		var explosion_object := explosion.duplicate() as AnimatedSprite2D
		explosion_object.visible = true
		explosion_object.global_position = Vector2(randf_range(330, 1000), randf_range(100, 500))
		add_child(explosion_object)

		explosion_object.play()

		explosion_object.animation_finished.connect(explosion_object.queue_free)
	await get_tree().create_timer(3).timeout
	
	GlobalSignalsManager.goose_fly_speed = 90
	get_tree().change_scene_to_file(main)
