extends CharacterBody2D
# Basic side-scroller player.
#
# This is the SHARED starting point for everyone. It only does the bare
# minimum: walk left/right, jump, and fall with gravity. Build your own
# mechanics (attacks, dashing, flight, health, etc.) on top of this.
#
# (Matthew's original top-down controller lives next to this as
# inputPlayerControl.gd if you need it.)

# --- Tuning (tweak these in the Inspector) ---
@export var move_speed: float = 220.0   # how fast we walk
@export var jump_force: float = 420.0    # upward push when we jump
@export var gravity: float = 1000.0      # how hard gravity pulls us down


func _physics_process(delta: float) -> void:
	# Gravity is always pulling us down while we're in the air
	if not is_on_floor():
		velocity.y += gravity * delta

	# Jump, but only when we're standing on the ground
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force

	# Walk left/right (A / D). get_axis gives -1, 0, or 1.
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * move_speed

	# Let the physics engine move us and handle collisions with the ground/walls
	move_and_slide()

	# Face the way we're walking
	if direction != 0.0:
		$Sprite2D.flip_h = direction < 0.0
