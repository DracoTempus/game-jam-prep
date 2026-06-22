extends Camera2D

@export var follow_speed: float = 5.0

@export var target: CharacterBody2D
@export var current_bounds: Area2D

var world_bounds: Rect2

func _ready() -> void:
	top_level = true
	make_current()
	set_area_bounds()
	global_position = target.global_position


func _physics_process(delta: float) -> void:
	if target == null:
		return

	var wanted_position: Vector2 = target.global_position
	var half_size: Vector2 = get_camera_half_size()

	global_position = global_position.lerp(wanted_position, follow_speed * delta)
	global_position = clamp_to_bounds(global_position, half_size)


func get_camera_half_size() -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size
	return viewport_size * 0.5 * zoom

func set_area_bounds() :
	var collision_shape: CollisionShape2D = current_bounds.get_node("CollisionShape2D")
	var rect_shape: RectangleShape2D = collision_shape.shape as RectangleShape2D

	var size: Vector2 = rect_shape.size * collision_shape.global_scale.abs()
	var top_left: Vector2 = collision_shape.global_position - size * 0.5
	world_bounds = Rect2(top_left, size)

func clamp_to_bounds(pos: Vector2, half_size: Vector2) -> Vector2:
	if current_bounds == null:
		return pos

	var left: float = world_bounds.position.x
	var right: float = world_bounds.position.x + world_bounds.size.x
	var top: float = world_bounds.position.y
	var bottom: float = world_bounds.position.y + world_bounds.size.y

	pos.x = clampf(pos.x, left + half_size.x, right - half_size.x)
	pos.y = clampf(pos.y, top + half_size.y, bottom - half_size.y)

	return pos
