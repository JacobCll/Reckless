class_name MainMenu
extends Control

@export var music: AudioStream

@export_group("Mouse Parallax")
@export var background_parallax_strength: Vector2 = Vector2(10.0, 5.0)
@export var logo_parallax_strength: Vector2 = Vector2(6.0, 3.0)
@export var parallax_smoothing: float = 5.0

@onready var settings_menu = $SettingsMenu
@onready var background: TextureRect = $Background
@onready var reckless_logo: TextureRect = $RecklessLogo

@onready var cutscene = $CanvasLayer/Cutscene

var _background_base_position: Vector2
var _logo_base_position: Vector2
var _parallax_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	GameManager.current_scene = "main_menu"
	AudioManager.play_music(music)
	MouseManager.show_mouse_trail()
	AudioManager.disable_mouse_sfx()
	
	if GameManager.show_cutscene:
		cutscene.show()
	else:
		cutscene.hide()
		
	_background_base_position = background.position
	_logo_base_position = reckless_logo.position

func _process(delta: float) -> void:
	var viewport_size := get_viewport_rect().size
	var mouse_pos := get_viewport().get_mouse_position()
	var normalized := (mouse_pos - viewport_size / 2.0) / (viewport_size / 2.0)
	normalized = normalized.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))

	_parallax_offset = _parallax_offset.lerp(normalized, min(parallax_smoothing * delta, 1.0))

	background.position = _background_base_position + _parallax_offset * background_parallax_strength
	reckless_logo.position = _logo_base_position + _parallax_offset * logo_parallax_strength

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

func _on_cutscene_continue_button_pressed() -> void:
	cutscene.hide()
