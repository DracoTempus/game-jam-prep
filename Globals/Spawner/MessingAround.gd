extends Resource
class_name MessingAround


@export var min: float = -500.0
@export var max: float = 500.0

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	if x_spawn_range == null or y_spawn_range == null:
		return

	var rect := Rect2(
		Vector2(x_spawn_range.min, y_spawn_range.min) - global_position,
		Vector2(
			x_spawn_range.max - x_spawn_range.min,
			y_spawn_range.max - y_spawn_range.min
		)
	)

	draw_rect(rect, Color(1, 0, 0, 0.15), true)
	draw_rect(rect, Color(1, 0, 0, 1), false, 2.0)
