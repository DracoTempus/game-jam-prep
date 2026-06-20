extends Area2D

@export var damage: int = 1

func attack() -> void:
	var bodies: Array[Node2D] = get_overlapping_bodies()

	for body in bodies:
		if body.is_in_group("enemies"):
			if body.has_method("Nouh_TellMe_method"):
				body.Nouh_TellMe_method(damage)
