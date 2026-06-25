extends Node

class_name NestHealth

signal health_changed(current: float, max: float)
signal died

func _ready() -> void:
	GlobalSignalsManager.nest_current_health = GlobalSignalsManager.nest_max_health


func take_damage(amount: float) -> void:
	if GlobalSignalsManager.nest_current_health <= 0.0:
		return
	GlobalSignalsManager.nest_current_health = max(GlobalSignalsManager.nest_current_health - amount, 0.0)
	health_changed.emit(GlobalSignalsManager.nest_current_health, GlobalSignalsManager.nest_max_health)
	if GlobalSignalsManager.nest_current_health <= 0.0:
		died.emit()

func heal(amount: float) -> void:
	GlobalSignalsManager.nest_current_health = min(GlobalSignalsManager.nest_current_health + amount, GlobalSignalsManager.nest_max_health)
	health_changed.emit(GlobalSignalsManager.nest_current_health, GlobalSignalsManager.nest_max_health)

func change_max_health(amount: float) -> void:
	GlobalSignalsManager.nest_max_health = min(1, GlobalSignalsManager.nest_max_health + amount)
	health_changed.emit(GlobalSignalsManager.nest_current_health, GlobalSignalsManager.nest_max_health)

func is_alive() -> bool:
	return GlobalSignalsManager.nest_current_health > 0.0
