extends Label

var default_values: Dictionary = {}


var stats := [
	{
		"name": "Nest Max Health",
		"key": "nest_max_health"
	},
	{
		"name": "Thrust Addition",
		"key": "fly_add_time"
	},
	{
		"name": "Max Thrust",
		"key": "max_fly_time"
	},
	{
		"name": "Starting Launch Thrust",
		"key": "launch_bonus_fly_time"
	},
	{
		"name": "Ground Speed",
		"key": "ground_speed"
	},
	{
		"name": "Fly Speed",
		"key": "fly_speed"
	},
	{
		"name": "Attack Damage",
		"key": "attack_damage"
	}
]


func _ready() -> void:
	save_default_values()
	update_stats_list()
	GlobalSignalsManager.stats_changed.connect(update_stats_list)


func save_default_values() -> void:
	for stat in stats:
		var key: String = stat["key"]
		default_values[key] = GlobalSignalsManager.get(key)


func update_stats_list() -> void:
	var lines: Array[String] = []

	for stat in stats:
		var display_name: String = stat["name"]
		var key: String = stat["key"]

		var default_value: float = default_values[key]
		var current_value: float = GlobalSignalsManager.get(key)
		var bonus_value: float = current_value - default_value

		lines.append(
			display_name + " : " + format_number(default_value) + " + " + format_number(bonus_value)
		)

	text = "\n".join(lines)


func format_number(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))

	return str(value)
