extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer

var music: AudioStream

func play_music(stream: AudioStream):
	if music_player.stream == stream and music_player.playing:
		return
	
	music_player.stream = stream
	music_player.play()

func stop_music():
	music_player.stop()

func pause_music() -> void:
	music_player.stream_paused = true
	
func resume_music() -> void:
	music_player.stream_paused = false

func enable_mouse_sfx():
	MouseSfx.enabled = true

func disable_mouse_sfx():
	MouseSfx.enabled = false
