extends Label

# Shows "You Win" or "Game Over" and pauses the game.
# Hidden until the game actually ends.

func _ready() -> void:
	# Stay hidden at the start.
	visible = false
	# Keep working even after we pause the game.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Listen for the three ways the game can end.
	GlobalSignalsManager.wave_cleared.connect(_on_win)
	GlobalSignalsManager.nest_destroyed.connect(_on_lose)
	GlobalSignalsManager.player_died.connect(_on_lose)


func _on_win() -> void:
	show_result("You Win!")


func _on_lose() -> void:
	show_result("Game Over")


func show_result(message: String) -> void:
	text = message
	visible = true
	# Freeze the game.
	get_tree().paused = true
