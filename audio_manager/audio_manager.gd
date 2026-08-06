extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var button_sfx_player: AudioStreamPlayer = $ButtonSfxPlayer

var music: AudioStream

var button_click_sfx := preload("res://sfx/button_press.wav")

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		node.pressed.connect(play_button_click)

func play_button_click() -> void:
	button_sfx_player.stream = button_click_sfx
	button_sfx_player.play()

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
