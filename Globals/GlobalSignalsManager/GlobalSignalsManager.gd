extends Node

signal player_health_changed(current: float, max: float)
signal player_died
signal nest_health_changed(current: float, max: float)
signal nest_destroyed
signal wave_cleared

@export_group("Global Variables")
@export var is_day_time = true

#Character Stats
@export_group("Character Stats")
@export var fly_time_left: float = 0.0
@export var fly_add_time: float = 0.25
@export var max_fly_time: float = 2.0
@export var launch_off_time: float = 0.2
@export var launch_bonus_fly_time: float = 1.0

@export var ground_speed: float = 130.0
@export var fly_speed: float = 230.0

@export var attack_damage: float = 1.0

@export_group("Wave")
@export var wave_size: int = 5

var _enemies_killed: int = 0

func enemy_was_killed() -> void:
	_enemies_killed += 1
	if _enemies_killed >= wave_size:
		_enemies_killed = 0
		wave_cleared.emit()
