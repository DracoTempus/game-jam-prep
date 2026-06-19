extends CharacterBody2D
@export var speed := 100.0

func _physics_process(delta):
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	else:
		velocity.y = 0
	move_and_slide()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
