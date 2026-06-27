extends Label

func _ready() -> void:
	GlobalSignalsManager.enemies_changed.connect(_on_enemies_changed)
	_on_enemies_changed(GlobalSignalsManager.enemies)


func _on_enemies_changed(current: int) -> void:
	if current > 0 :
		text = "Enemies Left :" + str(current)
	else :
		text = ""
