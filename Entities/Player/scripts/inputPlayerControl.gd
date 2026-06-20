extends CharacterBody2D


@export var ground_speed: float = 130.0
@export var fly_speed: float = 230.0

@export var fly_add_time: float = 0.25
@export var fly_max_time: float = 2.0
@export var launch_off_time: float = 0.2
@export var fly_launch_velocity: float = 600.0

@onready var flying_damage_box: Area2D = $FlyingDamageBox
@onready var flying_damage_shape: CollisionShape2D = $FlyingDamageBox/DamageShape

@onready var ground_damage_box: Area2D = $GroundMeleeDamageBox
@onready var ground_damage_shape: CollisionShape2D = $GroundMeleeDamageBox/DamageShape

var is_launching: bool = false
var launch_off_timer: float = 0.1

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float
var fly_time_left: float = 0.0
var is_flying: bool = false
var is_attacking: bool = false


func _physics_process(delta: float) -> void:
	if is_attacking:
		return
	
	if is_launching:
		launch_off_timer -= delta
		velocity.x = 0.0
		velocity.y = -fly_launch_velocity
		is_flying = true
		play_animation("flying")

		if launch_off_timer <= 0.01:
			is_launching = false

		move_and_slide()
		if Input.is_action_just_pressed("fly"):
				fly_time_left = min(fly_time_left + fly_add_time, fly_max_time)
		GlobalSignalsManager.fly_time_left = fly_time_left
		GlobalSignalsManager.max_fly_time = fly_max_time
		return
	
	var was_flying: bool = is_flying

	if Input.is_action_just_pressed("fly"):
		fly_time_left = min(fly_time_left + fly_add_time, fly_max_time)

	if fly_time_left > 0.0:
		fly_time_left -= delta
		is_flying = true
		if not was_flying:
			is_launching = true
			launch_off_timer = launch_off_time
	else:
		fly_time_left = 0.0
		is_flying = false

	if is_flying:
		var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity.x = input.x * fly_speed
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
	
	toggle_damage_box(is_flying)
	GlobalSignalsManager.fly_time_left = fly_time_left
	GlobalSignalsManager.max_fly_time = fly_max_time
	if is_on_floor() and is_flying and not is_launching:
		fly_time_left = 0.0
		is_flying = false

	if is_launching:
		play_animation("flying")
	elif is_flying:
		play_animation("flying")
	elif not is_on_floor() and velocity.y > 0.0:
		play_animation("idle_down")
	elif abs(velocity.x) > 0.0:
		play_animation("idle_down")
	else:
		play_animation("idle_down")
		
	if Input.is_action_just_pressed("attack") and not is_flying and not is_launching and not is_attacking:
		is_attacking = true
		play_animation("attack")
		ground_damage_box.attack()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	toggle_damage_box(false)

func _process(delta):
	pass

##Functions
func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		
func toggle_damage_box(active: bool) -> void:
	flying_damage_box.monitoring = active
	flying_damage_shape.disabled = not active

func play_animation(animation: String) -> void:
	if $AnimationPlayer.current_animation != animation:
		$AnimationPlayer.play(animation)
