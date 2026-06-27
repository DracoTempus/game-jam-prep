extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalSignalsManager.day_finished.connect(a_new_day)
	GlobalSignalsManager.day_started.connect(a_new_day)

func a_new_day() -> void:
	frame = 1

func a_new_night() -> void:
	frame = 0
