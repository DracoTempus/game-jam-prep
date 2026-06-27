extends Area2D

@export var target: Marker2D
@export var camera: Camera2D
@export var camera_bounds:Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") && GlobalSignalsManager.is_day_time == false:
		body.global_position = target.global_position
		camera.current_bounds = camera_bounds
		camera.set_area_bounds()
		camera.global_position = target.global_position
		
