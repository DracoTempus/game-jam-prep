extends Camera2D

@export var follow_speed: float = 5.0
@export var zoom_speed: float = 5.0

@export var normal_zoom: Vector2 = Vector2(1, 1)
@export var max_zoom: Vector2 = Vector2(4, 4)

@export var target: CharacterBody2D
@export var current_bounds: Area2D

var world_bounds: Rect2

func _ready() -> void:
	top_level = true
	make_current()
	set_area_bounds()

	if target != null:
		global_position = target.global_position

	zoom = normal_zoom


func _physics_process(delta: float) -> void:
	if target == null:
		return

	update_zoom_for_bounds(delta)

	var wanted_position: Vector2 = target.global_position
	var half_size: Vector2 = get_camera_half_size()

	global_position = global_position.lerp(wanted_position, follow_speed * delta)
	global_position = clamp_to_bounds(global_position, half_size)


func update_zoom_for_bounds(delta: float) -> void:
	if current_bounds == null:
		return

	var viewport_size: Vector2 = get_viewport_rect().size

	var needed_zoom_x: float = viewport_size.x / world_bounds.size.x
	var needed_zoom_y: float = viewport_size.y / world_bounds.size.y

	var needed_zoom_amount: float = max(needed_zoom_x, needed_zoom_y)

	var target_zoom_amount: float = max(
		normal_zoom.x,
		normal_zoom.y,
		needed_zoom_amount
	)

	var target_zoom: Vector2 = Vector2(target_zoom_amount, target_zoom_amount)
	target_zoom = target_zoom.clamp(normal_zoom, max_zoom)

	zoom = zoom.lerp(target_zoom, zoom_speed * delta)


func get_camera_half_size() -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size

	return Vector2(
		(viewport_size.x * 0.5) / zoom.x,
		(viewport_size.y * 0.5) / zoom.y
	)


func set_area_bounds() -> void:
	if current_bounds == null:
		return

	var collision_shape: CollisionShape2D = current_bounds.get_node("CollisionShape2D")
	var rect_shape: RectangleShape2D = collision_shape.shape as RectangleShape2D

	if rect_shape == null:
		return

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

	if half_size.x * 2.0 >= world_bounds.size.x:
		pos.x = world_bounds.get_center().x
	else:
		pos.x = clampf(pos.x, left + half_size.x, right - half_size.x)

	if half_size.y * 2.0 >= world_bounds.size.y:
		pos.y = world_bounds.get_center().y
	else:
		pos.y = clampf(pos.y, top + half_size.y, bottom - half_size.y)

	return pos
