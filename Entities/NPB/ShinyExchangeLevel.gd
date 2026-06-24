extends Area2D
var player_inside := false
var ui: Control = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	ui = get_tree().get_first_node_in_group("ExchangeUI")

	if ui:
		ui.visible = false
	else:
		push_warning("CANT FIND THAT UI")

func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		ui.visible = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_inside = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_inside = false
