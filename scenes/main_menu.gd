class_name MainMenu
extends TextureRect

@export var music: AudioStream

@onready var settings_menu = $SettingsMenu

func _ready() -> void:
	GameManager.current_scene = "main_menu"
	AudioManager.play_music(music) 
	AudioManager.disable_mouse_sfx()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_menu/level_menu.tscn")

func _on_settings_button_pressed() -> void:
	MouseManager.hide_mouse_trail()
	settings_menu.show()
