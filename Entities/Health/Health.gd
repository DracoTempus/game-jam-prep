extends Node
class_name Health

# Reusable health component. Add as a child of anything that can take damage.

@export var max_health: float = 3.0

var current_health: float = 0.0

signal health_changed(current: float, max: float)
signal died


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	if current_health <= 0.0:
		return
	current_health = max(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		died.emit()


func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func is_alive() -> bool:
	return current_health > 0.0
