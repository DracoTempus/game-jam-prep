extends ProgressBar

# A health bar that fills based on a global health signal.
# Set "target" to "player" or "nest" in the Inspector to pick
# which one this bar shows.

@export var target: String = "player"


func _ready() -> void:
	min_value = 0.0

	# Connect to the right signal, and find the thing we are showing
	# so we can fill the bar with its starting health right away.
	var owner_node: Node = null
	if target == "nest":
		GlobalSignalsManager.nest_health_changed.connect(_on_health_changed)
		owner_node = get_tree().get_first_node_in_group("nest")
	else:
		GlobalSignalsManager.player_health_changed.connect(_on_health_changed)
		owner_node = get_tree().get_first_node_in_group("Player")

	# Show the starting health now (before anything takes damage).
	if owner_node != null and owner_node.has_node("Health"):
		var h: Health = owner_node.get_node("Health")
		_on_health_changed(h.current_health, h.max_health)


func _on_health_changed(current: float, max: float) -> void:
	max_value = max
	value = current
