extends ProgressBar

func _ready() -> void:
	min_value = 0
	max_value = 100

func _process(delta: float) -> void:
	if GlobalSignalsManager.max_fly_time <= 0.0:
		value = 0.0
		return

	value = GlobalSignalsManager.fly_time_left / GlobalSignalsManager.max_fly_time * 100.0
