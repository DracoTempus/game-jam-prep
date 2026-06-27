extends "res://UI/stats_UI.gd"



func _ready() -> void:
	stats = [
		{
			"name": "Launch Time",
			"key": "launch_off_time"
		},
		{
			"name": "Goose Fly Speed",
			"key": "goose_fly_speed"
		},
		{
			"name": "Goose Peck Damage",
			"key": "goose_peck_damage"
		},
		{
			"name": "Goose Start Health",
			"key": "goose_start_health"
		}
	]

	super._ready()
