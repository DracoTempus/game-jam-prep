extends Node

@export var enemy_object: PackedScene
@export var entities_parent: Node

@export_group("Random Spawn Range")

@export_custom(PROPERTY_HINT_NONE,"SideBySideNumbers")
var min_x: float = -100.0
@export var max_x: float = 100.0

@export_custom(PROPERTY_HINT_NONE,"SideBySideNumbers")
var min_y: float = -100.0
@export var max_y: float = 100.0

@export_group("Spawn Timing")
@export var spawn_interval: float = .2

@export_group("Waves")
@export var start_waves_on_ready: bool = false
@export var wave_enemy_counts: Array[int]

@export_group("Wave Panel")
@export var wave_panel: Control
@export var wave_label: Label
@export var panel_fade_duration: float = 0.5
@export var panel_show_time: float = 2.0

var current_wave_index: int = -1
var alive_enemies: int = 0
var wave_running: bool = false

var timer: Timer

func _ready() -> void:		
	if wave_panel != null:
		wave_panel.visible = false
		wave_panel.modulate.a = 0.0

func spawn_enemy() -> Node:
	if enemy_object == null:
		push_warning("Spawner has no enemy_object assigned.")
		return null

	var enemy := enemy_object.instantiate()

	var random_x := randf_range(min_x, max_x)
	var random_y := randf_range(min_y, max_y)
	enemy.global_position = Vector2(random_x, random_y)

	var parent := entities_parent if entities_parent != null else get_parent()
	parent.add_child(enemy)

	return enemy

func start_waves() -> void:
	if wave_running:
		return

	if wave_enemy_counts.is_empty():
		push_warning("No waves assigned.")
		return

	var next_wave_index := current_wave_index + 1

	if next_wave_index >= wave_enemy_counts.size():
		await finish_game()
		return

	wave_running = true
	current_wave_index = next_wave_index

	await run_wave(current_wave_index)

	if current_wave_index >= wave_enemy_counts.size() - 1:
		await finish_game()
	else:
		wave_running = false
	
func run_wave(wave_index: int) -> void:
	var wave_number := wave_index + 1
	var enemy_count := wave_enemy_counts[wave_index]

	GlobalSignalsManager.day_started.emit(wave_number)

	await show_wave_panel("Wave " + str(wave_number))

	alive_enemies = 0
	GlobalSignalsManager.enemies = enemy_count
	for i in range(enemy_count):
		var enemy := spawn_enemy()

		if enemy != null:
			alive_enemies += 1
			enemy.tree_exited.connect(_on_spawned_enemy_removed)

		if spawn_interval > 0.0:
			await get_tree().create_timer(spawn_interval).timeout

	while alive_enemies > 0:
		GlobalSignalsManager.enemies = alive_enemies
		await get_tree().process_frame

	GlobalSignalsManager.enemies = 0
	GlobalSignalsManager.day_finished.emit()
	
	print("DAY FINISHED")

func _on_spawned_enemy_removed() -> void:
	alive_enemies -= 1
	alive_enemies = max(alive_enemies, 0)

func show_wave_panel(text: String) -> void:
	if wave_panel == null:
		return

	if wave_label != null:
		wave_label.text = text

	wave_panel.visible = true
	wave_panel.modulate.a = 0.0

	var fade_in := create_tween()
	fade_in.tween_property(wave_panel, "modulate:a", 1.0, panel_fade_duration)
	await fade_in.finished

	await get_tree().create_timer(panel_show_time).timeout

	var fade_out := create_tween()
	fade_out.tween_property(wave_panel, "modulate:a", 0.0, panel_fade_duration)
	await fade_out.finished

	wave_panel.visible = false

func finish_game() -> void:
	GlobalSignalsManager.game_win.emit()
	wave_running = false
	get_tree().change_scene_to_file("res://Menus/Win.tscn")
