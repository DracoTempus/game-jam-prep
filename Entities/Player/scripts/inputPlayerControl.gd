extends CharacterBody2D

@export var ground_speed: float = 130.0
@export var fly_speed: float = 200.0

@export var fly_add_time: float = 5.0
@export var fly_max_time: float = 8.0
@export var fly_launch_velocity: float = 1600.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float
var fly_time_left: float = 0.0
var is_flying: bool = false

func _physics_process(delta: float) -> void:
	var was_flying: bool = is_flying

	if Input.is_action_just_pressed("fly"):
		fly_time_left = min(fly_time_left + fly_add_time, fly_max_time)

		if not was_flying:
			velocity.y = -fly_launch_velocity

	if fly_time_left > 0.0:
		fly_time_left -= delta
		is_flying = true
	else:
		fly_time_left = 0.0
		is_flying = false

	if is_flying:
		var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity.x = input.x * fly_speed

		if Input.is_action_just_pressed("fly") and not was_flying:
			velocity.y = -fly_launch_velocity
		else:
			velocity.y = input.y * fly_speed

	else:
		var direction: float = Input.get_axis("move_left", "move_right")
		velocity.x = direction * ground_speed

		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.y = 0.0

	if velocity.x != 0.0:
		$Sprite2D.flip_h = velocity.x > 0.0

	move_and_slide()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
