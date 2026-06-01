class_name MainMenu
extends TextureRect

@export var music: AudioStream

@onready var settings_menu = $SettingsMenu

func _ready() -> void:
	MusicManager.play_music(music) # play main menu music

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_menu/level_menu.tscn")

func _on_settings_button_pressed() -> void:
	settings_menu.show()
