extends Area2D

func attack() -> void:
	var bodies: Array[Node2D] = get_overlapping_bodies()

	for body in bodies:
		if body.is_in_group("Enemies"):
			if body.has_method("take_damage"):
				body.take_damage(GlobalSignalsManager.attack_damage)
