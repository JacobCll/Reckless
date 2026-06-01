extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer

var music: AudioStream

func play_music(stream: AudioStream):
	music_player.stream = stream
	music_player.play()

func stop_music():
	music_player.stop()
