extends CharacterBody2D

@export var fly_launch_velocity: float = 600.0

@onready var flying_damage_box: Area2D = $FlyingDamageBox
@onready var flying_damage_shape: CollisionShape2D = $FlyingDamageBox/DamageShape

@onready var ground_damage_box: Area2D = $GroundMeleeDamageBox
@onready var ground_damage_shape: CollisionShape2D = $GroundMeleeDamageBox/DamageShape

@export var wind_up_animation_playing: bool = false

var is_launching: bool = false
var launch_off_timer: float = 0.1

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float

var is_flying: bool = false
var is_attacking: bool = false

func _physics_process(delta: float) -> void:
	if is_attacking:
		return
	
	if is_launching:
		if wind_up_animation_playing == false:
			launch_off_timer -= delta
			velocity.x = 0.0
			velocity.y = -fly_launch_velocity
			is_flying = true

			if launch_off_timer <= 0.01:
				is_launching = false

		move_and_slide()
		if Input.is_action_just_pressed("fly"):
				GlobalSignalsManager.fly_time_left = min(GlobalSignalsManager.fly_time_left + GlobalSignalsManager.fly_add_time, GlobalSignalsManager.max_fly_time)
		return
	
	var was_flying: bool = is_flying
	
	if is_flying:
		var input: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity.x = input.x * GlobalSignalsManager.fly_speed
		velocity.y = input.y * GlobalSignalsManager.fly_speed

	else:
		var direction: float = Input.get_axis("move_left", "move_right")
		velocity.x = direction * GlobalSignalsManager.ground_speed
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.y = 0.0

	if Input.is_action_just_pressed("fly"):
		if is_flying == true || is_on_floor():
			GlobalSignalsManager.fly_time_left = min(GlobalSignalsManager.fly_time_left + GlobalSignalsManager.fly_add_time, GlobalSignalsManager.max_fly_time)

	if GlobalSignalsManager.fly_time_left > 0.0:
		GlobalSignalsManager.fly_time_left -= delta
		is_flying = true
		
		if not was_flying:
			velocity.x = 0.0
			velocity.y = 0.0
			wind_up_animation_playing = true
			is_launching = true
			GlobalSignalsManager.fly_time_left = GlobalSignalsManager.launch_bonus_fly_time
			launch_off_timer = GlobalSignalsManager.launch_off_time
	else:
		GlobalSignalsManager.fly_time_left = 0.0
		is_flying = false

	if velocity.x != 0.0:
		$Sprite2D.flip_h = velocity.x > 0.0

	move_and_slide()
	
	toggle_damage_box(is_flying)
	
	if is_on_floor() and is_flying and not is_launching:
		GlobalSignalsManager.fly_time_left = 0.0
		is_flying = false

	if is_launching:
		play_animation("wind_up")
	elif is_flying:
		play_animation("flying")
	elif not is_on_floor() and velocity.y > 0.0:
		play_animation("idle_down")
	elif abs(velocity.x) > 0.0:
		play_animation("idle_down")
	else:
		play_animation("idle_down")
		
	if Input.is_action_just_pressed("attack") and not is_flying and not is_launching and not is_attacking and is_on_floor():
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
