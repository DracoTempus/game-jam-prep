extends Node

@export var enemy_object: PackedScene
@export var entities_parent: Node

@export_group("Random Spawn Range")

#@export_custom(PROPERTY_HINT_NONE, "RangeSlider:-1000,1000,100,Range X")
@export_custom(PROPERTY_HINT_NONE,"SideBySideNumbers")
var min_x: int = -100.0
@export var max_x: int = 100.0

@export_custom(PROPERTY_HINT_NONE,"SideBySideNumbers")
var min_y: float = -100.0
@export var max_y: float = 100.0


@export_group("Spawn Timing")
@export var spawn_on_ready: bool = true
@export var spawn_interval: float = 1.0
@export var auto_spawn: bool = false

var timer: Timer

func _ready() -> void:		
	if spawn_on_ready:
		spawn_enemy()

	if auto_spawn:
		timer = Timer.new()
		timer.wait_time = spawn_interval
		timer.autostart = true
		timer.timeout.connect(spawn_enemy)
		add_child(timer)


func spawn_enemy() -> void:
	if enemy_object == null:
		push_warning("Spawner has no enemy_scene assigned.")
		return
	
	var enemy = enemy_object.instantiate()

	var random_x = randf_range(min_x, max_x)
	var random_y = randf_range(min_y, max_y)
	enemy.global_position = Vector2(random_x, random_y)
	
	entities_parent.add_child(enemy)
