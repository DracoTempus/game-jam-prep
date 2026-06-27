extends Node

var music_player: AudioStreamPlayer

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)


func play_music(track: AudioStream, volume_db: float = -10.0) -> void:
	if track == null:
		return

	music_player.stop()
	music_player.stream = track
	music_player.volume_db = volume_db
	music_player.play()


func stop_music() -> void:
	music_player.stop()


func pause_music() -> void:
	music_player.stream_paused = true


func resume_music() -> void:
	music_player.stream_paused = false


func change_music(track: AudioStream, volume_db: float = -10.0) -> void:
	play_music(track, volume_db)
