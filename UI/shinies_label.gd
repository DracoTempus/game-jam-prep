extends Label

func _ready() -> void:
	GlobalSignalsManager.shinies_changed.connect(_on_shinies_changed)
	_on_shinies_changed(GlobalSignalsManager.shinies)


func _on_shinies_changed(current: int) -> void:
	text = "Shinies:" + str(current)
