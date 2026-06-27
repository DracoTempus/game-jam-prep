extends "res://Levels/scripts/CasinoDoors.gd"

var player_in_door: bool = false
var Player: Node2D
@export var casino_music: AudioStream
@export var night_music: AudioStream
@export var volume_db: float = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if Player == null:
		return
		
	if player_in_door == false:
		return

	if Input.is_action_just_pressed("interact") and player_in_door:
		Player.global_position = target.global_position
		camera.current_bounds = camera_bounds
		camera.set_area_bounds()
		camera.global_position = target.global_position
		Musicplayer.play_music(night_music, volume_db)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Player = body
		player_in_door = true
		Musicplayer.play_music(casino_music, volume_db)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_door = false
		Player = null
		
