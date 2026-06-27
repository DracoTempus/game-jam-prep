extends Node2D

@onready var health: NestHealth = $Health
@export var interact_area: Area2D

@export var Daytime_fake_panel: Panel

@export var sleep_ui: Control
@export var dont_wave: Control
@export var wave_spawner: Node

var player_in_area := false

func _ready() -> void:
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)

	GlobalSignalsManager.day_finished.connect(a_new_day)
	interact_area.body_entered.connect(_on_interact_area_body_entered)
	interact_area.body_exited.connect(_on_interact_area_body_exited)
	
	sleep_ui.visible = false
	dont_wave.visible = false
	Daytime_fake_panel.modulate.a = 0

func a_new_day() -> void:
	GlobalSignalsManager.is_day_time = false
	
	var fade_out_tween := create_tween()
	fade_out_tween.tween_property(Daytime_fake_panel, "modulate:a", 0, 1.5)
	health.heal(GlobalSignalsManager.trash)
	GlobalSignalsManager.trash = 0

func _process(_delta: float) -> void:
	if not player_in_area:
		return

	if GlobalSignalsManager.is_day_time:
		return

	if Input.is_action_just_pressed("interact"):
		start_wave()

func take_damage(amount: float) -> void:
	health.take_damage(amount)

func _on_health_changed(current: float, max: float) -> void:
	GlobalSignalsManager.nest_health_changed.emit(current, max)

func _on_died() -> void:
	get_tree().change_scene_to_file("res://Levels/lose.tscn")

func _on_interact_area_body_entered(body: Node) -> void:
	if body.is_in_group("Player") && GlobalSignalsManager.is_day_time == false && GlobalSignalsManager.shinies <= 0:
		player_in_area = true
		sleep_ui.visible = true
	elif body.is_in_group("Player") && GlobalSignalsManager.is_day_time == false && GlobalSignalsManager.shinies > 0:
		dont_wave.visible = true
		

func _on_interact_area_body_exited(body: Node) -> void:
	if body.is_in_group("Player") && GlobalSignalsManager.is_day_time == false:
		player_in_area = false
		sleep_ui.visible = false
		dont_wave.visible = false

func start_wave() -> void:
	GlobalSignalsManager.is_day_time = true

	sleep_ui.visible = false
	wave_spawner.start_waves()
	player_in_area = false
	sleep_ui.visible = false
	dont_wave.visible = false
	
	Daytime_fake_panel.modulate.a = 0.0
	var fade_out_tween := create_tween()
	fade_out_tween.tween_property(Daytime_fake_panel, "modulate:a", 1.0, 1.5)
	
