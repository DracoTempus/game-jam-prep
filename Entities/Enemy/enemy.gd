extends CharacterBody2D

# A simple enemy.
# It flies toward the nest, pecks the nest when it gets there,
# and hurts the player if they touch it. The player can kill it
# with melee attacks (see MeleeAttack.gd).

# How fast it flies toward the nest.
@export var move_speed: float = 90.0

# Nest pecking.
@export var peck_damage: float = 1.0      # damage per peck
@export var peck_interval: float = 1.0    # seconds between pecks
@export var peck_range: float = 60.0      # how close it must be to peck

# Touching the player.
@export var contact_damage: float = 1.0     # damage when it touches the player
@export var contact_cooldown: float = 1.0   # seconds before it can hurt again

@onready var health: Health = $Health
# This box checks if we are touching the player.
@onready var contact_box: Area2D = $ContactBox

# Filled in _ready: the nest we are attacking.
var nest: Node2D = null

# Timers that count down.
var peck_timer: float = 0.0
var contact_timer: float = 0.0


func _ready() -> void:
	# When our health runs out, die.
	# (The spawner sets the total wave size, not each enemy.)
	health.died.connect(_on_died)

	# Find the nest by its group.
	nest = get_tree().get_first_node_in_group("nest")


func _physics_process(delta: float) -> void:
	# Tick down our timers.
	if peck_timer > 0.0:
		peck_timer -= delta
	if contact_timer > 0.0:
		contact_timer -= delta

	if nest != null:
		var to_nest: Vector2 = nest.global_position - global_position
		var distance: float = to_nest.length()

		if distance > peck_range:
			# Still far: fly toward the nest.
			velocity = to_nest.normalized() * move_speed
		else:
			# Close enough: stop and peck on a timer.
			velocity = Vector2.ZERO
			if peck_timer <= 0.0:
				peck_nest()
				peck_timer = peck_interval
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Hurt the player if we are touching them.
	check_player_contact()


# This is the method the player's melee calls to damage us.
# (Keeping the same name Matthew's MeleeAttack.gd already uses.)
func Nouh_TellMe_method(damage: float) -> void:
	health.take_damage(damage)


func peck_nest() -> void:
	if nest != null and nest.has_method("take_damage"):
		nest.take_damage(peck_damage)


func check_player_contact() -> void:
	# Still on cooldown, skip.
	if contact_timer > 0.0:
		return

	for body in contact_box.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(contact_damage)
			contact_timer = contact_cooldown
			return


func _on_died() -> void:
	# Tell the game one enemy is gone, then remove ourselves.
	GlobalSignalsManager.enemy_was_killed()
	queue_free()
