extends CharacterBody2D
@export var move_speed := 100.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float
@export var is_flying :bool=false;

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_flying :
		var input :Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = input * move_speed

	else:
		var direction :float= Input.get_axis("move_left", "move_right")
		velocity.x = direction * move_speed

	if velocity.x != 0.0:
		$Sprite2D.flip_h = velocity.x > 0.0

	move_and_slide()





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
