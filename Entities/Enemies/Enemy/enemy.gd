extends CharacterBody2D

@export var peck_interval: float = 1.0 
@export var peck_range: float = 60.0

@export var contact_damage: float = 1.0
@export var contact_cooldown: float = 1.0 

@onready var health: Health = $Health
@export var pickup_scene: PackedScene

var pickup_drop_chance: float = 0.3
var nest: Node2D = null
var peck_timer: float = 0.0
var contact_timer: float = 0.0

func _ready() -> void:
	health.died.connect(_on_died)
	nest = get_tree().get_first_node_in_group("nest")
	if nest == null:
		print("FOUND NEST")

func _physics_process(delta: float) -> void:
	if peck_timer > 0.0:
		peck_timer -= delta
	if contact_timer > 0.0:
		contact_timer -= delta

	if nest != null:
		var to_nest: Vector2 = nest.global_position - global_position
		var distance: float = to_nest.length()

		if distance > peck_range:
			velocity = to_nest.normalized() * GlobalSignalsManager.goose_fly_speed
		else:
			velocity = Vector2.ZERO
			if peck_timer <= 0.0:
				peck_nest()
				peck_timer = peck_interval
	else:
		velocity = Vector2.ZERO

	if velocity.x > 0.0:
		$Sprite2D.flip_h = true
	elif velocity.x < 0.0:
		$Sprite2D.flip_h = false
	move_and_slide()

func take_damage(damage: float) -> void:
	health.take_damage(damage)
	blinkSprite()

func blinkSprite() -> void:
	var sprite := $Sprite2D
	var blink_time := 0.3 / 6.0
	
	for i in 3:
		sprite.modulate = Color(1, 0, 0, 1) # red
		await get_tree().create_timer(blink_time).timeout
		
		sprite.modulate = Color(1, 1, 1, 1) # white
		await get_tree().create_timer(blink_time).timeout

func peck_nest() -> void:
	if nest != null and nest.has_method("take_damage"):
		nest.take_damage(GlobalSignalsManager.goose_peck_damage)

func spawn_pickup() -> void:
	if randf() < pickup_drop_chance:
		return

	var pickup: Node2D = pickup_scene.instantiate() as Node2D
	if randf() < 0.25:
		pickup.is_trash = false
		
	await get_tree().physics_frame
	pickup.spawnSetup()
	get_parent().add_child(pickup)
	pickup.global_position = global_position

func _on_died() -> void:
	await spawn_pickup()
	queue_free()
