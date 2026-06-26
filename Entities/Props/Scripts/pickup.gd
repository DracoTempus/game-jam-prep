extends RigidBody2D

@export var min_spin: float = 4.0
@export var max_spin: float = 10.0

@export var min_pop_x: float = -40.0
@export var max_pop_x: float = 40.0
@export var min_pop_y: float = -90.0
@export var max_pop_y: float = -40.0

@export var trash: Array[Texture2D] = []
@export var shiny: Array[Texture2D] = []
@export var sprite: Sprite2D
@export var pickup_area: Area2D

@export var is_trash = true

var time_alive: float = 0

func _ready() -> void:
	pickup_area.body_entered.connect(_on_pickup_area_body_entered)
	rotation = randf_range(0.0, TAU)

	var spin_direction: float = -1.0 if randf() < 0.5 else 1.0
	angular_velocity = randf_range(min_spin, max_spin) * spin_direction

	linear_velocity = Vector2(
		randf_range(min_pop_x, max_pop_x),
		randf_range(min_pop_y, max_pop_y)
	)

func _physics_process(delta: float) -> void:
	if time_alive < 2:
		time_alive += delta
	

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") && time_alive > 0.5:
		if is_trash:
			GlobalSignalsManager.trash += 1
		else:
			GlobalSignalsManager.shinies += 1
		queue_free()

func spawnSetup() -> void:
	if is_trash:
		var random_index: int = randi_range(0, trash.size() - 1)
		sprite.texture = trash[random_index]
	else:
		var random_index: int = randi_range(0, shiny.size() - 1)
		sprite.texture = shiny[random_index]
	
