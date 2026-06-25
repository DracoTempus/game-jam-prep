extends Node2D

# The nest the player must protect.
# Enemies peck it. When its health hits zero, the game is lost.

@onready var health : NestHealth = $Health


func _ready() -> void:
	# Update the HUD bar and tell the game when the nest dies.
	# (The HUD reads our starting health on its own, so we only
	#  need to tell it about later changes.)
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)


# Enemies call this to damage the nest.
func take_damage(amount: float) -> void:
	health.take_damage(amount)


func _on_health_changed(current: float, max: float) -> void:
	GlobalSignalsManager.nest_health_changed.emit(current, max)


func _on_died() -> void:
	GlobalSignalsManager.nest_destroyed.emit()
