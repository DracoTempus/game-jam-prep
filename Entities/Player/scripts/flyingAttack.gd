extends Area2D

@export var damage_interval: float = 0.25

var bodies_inside: Array[Node2D] = []
var damage_timer: Timer


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	damage_timer = Timer.new()
	damage_timer.wait_time = damage_interval
	damage_timer.one_shot = false
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	add_child(damage_timer)
	damage_timer.start()


func _on_body_entered(body: Node2D) -> void:
	print(body.name)

	if body.is_in_group("Enemies") and body.has_method("take_damage"):
		if not bodies_inside.has(body):
			bodies_inside.append(body)

		_damage_body(body)


func _on_body_exited(body: Node2D) -> void:
	if bodies_inside.has(body):
		bodies_inside.erase(body)


func _on_damage_timer_timeout() -> void:
	for body in bodies_inside.duplicate():
		if not is_instance_valid(body):
			bodies_inside.erase(body)
			continue

		_damage_body(body)


func _damage_body(body: Node2D) -> void:
	if body.is_in_group("Enemies") and body.has_method("take_damage"):
		body.take_damage(GlobalSignalsManager.attack_damage)
