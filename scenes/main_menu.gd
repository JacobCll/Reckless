class_name MainMenu
extends Control

@export var music: AudioStream

@onready var settings_menu = $SettingsMenu

func _ready() -> void:
	GameManager.current_scene = "main_menu"
	AudioManager.play_music(music) 
	AudioManager.disable_mouse_sfx()
	MouseManager.show_mouse_trail()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_menu/level_menu.tscn")

func _on_settings_button_pressed() -> void:
	MouseManager.hide_mouse_trail()
	settings_menu.show()

func _on_shop_button_pressed() -> void:
	MouseManager.hide_mouse_trail()
	get_tree().change_scene_to_file("res://shop/shop.tscn")

func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/tutorial_level/tutorial_level.tscn")

func _on_notification_button_pressed() -> void:
	get_tree().change_scene_to_file("res://notification/notificationscreen.tscn")
