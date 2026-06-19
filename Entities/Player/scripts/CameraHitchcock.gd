extends Camera2D

@export var follow_speed: float = 5.0

@export var left_bound: Node2D
@export var right_bound: Node2D
@export var bottom_bound: Node2D
@export var target: CharacterBody2D

func _ready() -> void:
	top_level = true
	make_current()

	global_position = target.global_position


func _physics_process(delta: float) -> void:
	if target == null:
		return

	var wanted_position: Vector2 = target.global_position
	var half_size: Vector2 = get_camera_half_size()

	global_position = global_position.lerp(wanted_position, follow_speed * delta)
	global_position = clamp_to_world_bounds(global_position, half_size)


func get_camera_half_size() -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size
	return viewport_size * 0.5 * zoom


func clamp_to_world_bounds(pos: Vector2, half_size: Vector2) -> Vector2:
	if left_bound != null:
		pos.x = max(pos.x, left_bound.global_position.x + half_size.x)

	if right_bound != null:
		pos.x = min(pos.x, right_bound.global_position.x - half_size.x)

	if bottom_bound != null:
		pos.y = min(pos.y, bottom_bound.global_position.y - half_size.y)

	return pos
