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

@export_group("To Be Continued Page")
@export var to_be_continued_background_brightness: float = 0.4
@export var background_dim_duration: float = 0.25
@export_group("")

@onready var level_grid := $LevelGrid

@onready var background: TextureRect = $Background
@onready var levels_text: TextureRect = $LevelsText
@onready var back_button: TextureButton = $BackButton
@onready var to_be_continued_page: Control = $ToBeContinuedPage
@onready var left_arrow: ArrowButton = $LeftArrow
@onready var right_arrow: ArrowButton = $RightArrow

@onready var powerup_modal: PowerupModal = $PowerupModal

var levels = 10

var _background_base_position: Vector2
var _logo_base_position: Vector2
var _level_grid_base_position: Vector2
var _back_button_base_position: Vector2
var _to_be_continued_page_base_position: Vector2
var _left_arrow_base_position: Vector2
var _right_arrow_base_position: Vector2
var _parallax_offset: Vector2 = Vector2.ZERO
var _background_base_modulate: Color
var _background_tween: Tween

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
	_background_base_modulate = background.modulate
	_logo_base_position = levels_text.position
	_level_grid_base_position = level_grid.position
	_back_button_base_position = back_button.position
	_to_be_continued_page_base_position = to_be_continued_page.position
	_left_arrow_base_position = left_arrow.position
	_right_arrow_base_position = right_arrow.position

	# the "to be continued" page is only reachable once the last level is beaten
	if GameManager.final_level_completed:
		_show_page(0)

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
	to_be_continued_page.position = _to_be_continued_page_base_position + _parallax_offset * buttons_parallax_strength
	left_arrow.position = _left_arrow_base_position + _parallax_offset * buttons_parallax_strength
	right_arrow.position = _right_arrow_base_position + _parallax_offset * buttons_parallax_strength

# page 0 is the level grid, page 1 is the "to be continued" message
func _show_page(page: int) -> void:
	level_grid.visible = page == 0
	to_be_continued_page.visible = page == 1
	left_arrow.visible = page == 1
	right_arrow.visible = page == 0

	# dim the background behind the "to be continued" message
	var target_modulate := _background_base_modulate
	if page == 1:
		target_modulate = Color(Color.WHITE * to_be_continued_background_brightness, _background_base_modulate.a)

	if _background_tween:
		_background_tween.kill()
	_background_tween = create_tween()
	_background_tween.tween_property(background, "modulate", target_modulate, background_dim_duration)

func _on_level_selected(path, level_number: int) -> void:
	powerup_modal.open(level_number, path)

func _on_left_arrow_pressed() -> void:
	_show_page(0)

func _on_right_arrow_pressed() -> void:
	_show_page(1)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	powerup_modal.close()
