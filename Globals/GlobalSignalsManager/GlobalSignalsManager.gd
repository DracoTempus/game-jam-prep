extends Node

signal player_health_changed(current: float, max: float)
signal player_died
signal nest_health_changed(current: float, max: float)
signal nest_destroyed
signal day_finished
signal day_started
signal game_win
signal shinies_changed(current: int)
signal trash_changed(current: int)
signal enemies_changed(current: int)


@export_group("Player Stats")
@export var trash: int = 0:
	set(value):
		if trash == value:
			return

		trash = value
		trash_changed.emit(trash)

@export var shinies: int = 2:
	set(value):
		if shinies == value:
			return

		shinies = value
		shinies_changed.emit(shinies)

@export_group("Nest Stats")
@export var nest_max_health: float = 3.0
@export var nest_current_health: float = 3.0

@export_group("Character Stats")
@export var fly_time_left: float = 0.0
@export var fly_add_time: float = 0.25
@export var max_fly_time: float = 2.0
@export var launch_off_time: float = 0.2
@export var launch_bonus_fly_time: float = 1.0
@export var ground_speed: float = 200.0
@export var fly_speed: float = 300.0
@export var attack_damage: float = 1.0

@export_group("Wave")
@export var is_day_time = false
@export var wave_size: int = 5
@export var goose_fly_speed: float = 90.0
@export var goose_peck_damage: float = 1.0
@export var goose_start_health: float = 3.0

@export var enemies: int = 0:
	set(value):
		if enemies == value:
			return

		enemies = value
		enemies_changed.emit(enemies)
