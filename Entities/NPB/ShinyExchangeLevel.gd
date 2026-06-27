extends Area2D
var player_inside := false
var slotUI: Control = null
@export var my_label: Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	slotUI = get_tree().get_first_node_in_group("ExchangeUI")

	if slotUI:
		slotUI.visible = false

func _process(_delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact") and GlobalSignalsManager.shinies > 0:
		slotUI.visible = true
		slotUI.shinies = GlobalSignalsManager.shinies
		GlobalSignalsManager.shinies = 0
		my_label.text = "Thanks for playing"
		slotUI.update_shiny_label()
		GlobalSignalsManager.update_stats_ui()

func _on_body_entered(body: Node2D) -> void:
	if GlobalSignalsManager.shinies > 0:
		my_label.text = "Play the slots for chance to get stats."
	else:
		my_label.text = "Go find shinies and come back"
		
	if body.is_in_group("Player"):
		player_inside = true

func _on_body_exited(body: Node2D) -> void:
	if GlobalSignalsManager.shinies > 0:
		my_label.text = "I know you got shinies, how about you come back and give them to me."
	else:
		my_label.text = "Let me know when you get some more shinies"
	
	if body.is_in_group("Player"):
		player_inside = false
