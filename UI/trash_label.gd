extends Label

func _ready() -> void:
	GlobalSignalsManager.trash_changed.connect(_on_trash_changed)
	_on_trash_changed(GlobalSignalsManager.trash)


func _on_trash_changed(current: int) -> void:
	text = "Trash:" + str(current)
