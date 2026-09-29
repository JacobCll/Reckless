class_name LevelMenu
extends Control

@export var level_button: PackedScene
@export var level_menu_music: AudioStream

@export_group("Mouse Parallax")
@export var background_parallax_strength: Vector2 = Vector2(10.0, 5.0)
@export var logo_parallax_strength: Vector2 = Vector2(6.0, 3.0)
@export var buttons_parallax_strength: Vector2 = Vector2(3.0, 1.5)
@export var parallax_smoothing: float = 5.0
@export_group("")

@onready var level_grid := $LevelGrid

@onready var background: TextureRect = $Background
@onready var levels_text: TextureRect = $LevelsText
@onready var back_button: TextureButton = $BackButton

@onready var powerup_modal: PowerupModal = $PowerupModal

var levels = 10

var _background_base_position: Vector2
var _logo_base_position: Vector2
var _level_grid_base_position: Vector2
var _back_button_base_position: Vector2
var _parallax_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	AudioManager.play_music(level_menu_music)
	AudioManager.disable_mouse_sfx()
	GameManager.current_scene = "level_menu"

	var grid = $LevelGrid
	grid.columns = 5

	for button in level_grid.get_children():
		button.level_selected.connect(_on_level_selected.bind(button.level_number))

		# disable if not unlocked
		if not GameManager.is_level_unlocked(button.level_number):
			button.disabled = true
			button.mouse_default_cursor_shape = Control.CURSOR_ARROW

	_background_base_position = background.position
	_logo_base_position = levels_text.position
	_level_grid_base_position = level_grid.position
	_back_button_base_position = back_button.position

func _process(delta: float) -> void:
	var viewport_size := get_viewport_rect().size
	var mouse_pos := get_viewport().get_mouse_position()
	var normalized := (mouse_pos - viewport_size / 2.0) / (viewport_size / 2.0)
	normalized = normalized.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))

	_parallax_offset = _parallax_offset.lerp(normalized, min(parallax_smoothing * delta, 1.0))

	background.position = _background_base_position + _parallax_offset * background_parallax_strength
	levels_text.position = _logo_base_position + _parallax_offset * logo_parallax_strength
	level_grid.position = _level_grid_base_position + _parallax_offset * buttons_parallax_strength
	back_button.position = _back_button_base_position + _parallax_offset * buttons_parallax_strength

func _on_level_selected(path, level_number: int) -> void:
	powerup_modal.open(level_number, path)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	powerup_modal.close()
