class_name LevelMenu
extends Control

@export var level_button: PackedScene
@export var level_menu_music: AudioStream

@export_group("Mouse Parallax")
@export var background_parallax_strength: Vector2 = Vector2(10.0, 5.0)
@export var logo_parallax_strength: Vector2 = Vector2(6.0, 3.0)
@export var parallax_smoothing: float = 5.0
@export_group("")

@onready var level_grid := $LevelGrid

@onready var background: TextureRect = $Background
@onready var levels_text: TextureRect = $LevelsText

@export var powerup_card_scene: PackedScene
@onready var powerup_modal := $CanvasLayer/PowerupModal
@onready var powerup_grid := $CanvasLayer/PowerupModal/ScrollContainer/MarginContainer/PowerupGrid

var levels = 10
var selected_level_path := ""

var selected_powerup_card: PowerupCard = null

var _background_base_position: Vector2
var _logo_base_position: Vector2
var _parallax_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	AudioManager.play_music(level_menu_music)
	AudioManager.disable_mouse_sfx()
	GameManager.current_scene = "level_menu"
	
	powerup_modal.hide()

	var grid = $LevelGrid
	grid.columns = 5

	for button in level_grid.get_children():
		button.level_selected.connect(_on_level_selected)

		# disable if not unlocked
		if not GameManager.is_level_unlocked(button.level_number):
			button.disabled = true
			button.mouse_default_cursor_shape = Control.CURSOR_ARROW

	_background_base_position = background.position
	_logo_base_position = levels_text.position

func _process(delta: float) -> void:
	var viewport_size := get_viewport_rect().size
	var mouse_pos := get_viewport().get_mouse_position()
	var normalized := (mouse_pos - viewport_size / 2.0) / (viewport_size / 2.0)
	normalized = normalized.clamp(Vector2(-1.0, -1.0), Vector2(1.0, 1.0))

	_parallax_offset = _parallax_offset.lerp(normalized, min(parallax_smoothing * delta, 1.0))

	background.position = _background_base_position + _parallax_offset * background_parallax_strength
	levels_text.position = _logo_base_position + _parallax_offset * logo_parallax_strength

func _on_level_selected(path) -> void:
	selected_level_path = path
	
	powerup_modal.show()
	
	populate_powerups()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	selected_level_path = ""
	selected_powerup_card = null
	GameManager.selected_powerup = ""

func _on_start_button_pressed() -> void:
	if selected_level_path == "":
		return
		
	LoadingScreen.transition_to(get_tree(), selected_level_path)

func _on_cancel_button_pressed() -> void:
	selected_level_path = ""
	selected_powerup_card = null
	GameManager.selected_powerup = ""
	
	powerup_modal.hide()
	
func populate_powerups():
	for child in powerup_grid.get_children():
		child.queue_free()
		
	for item_id in GameManager.inventory:
		if GameManager.inventory[item_id] <= 0:
			continue
		
		var card = powerup_card_scene.instantiate()
		
		card.item_id = item_id
		card.powerup_name = GameManager.item_info[item_id]["display_name"]
		card.quantity_owned = GameManager.inventory[item_id]
		card.texture_path = GameManager.item_info[item_id]["texture"]
		
		card.selected.connect(select_powerup)
		
		powerup_grid.add_child(card)

func select_powerup(card: PowerupCard):
	# deselects it if you click the same card
	if selected_powerup_card == card:
		card.set_selected(false)
		selected_powerup_card = null
		return
	
	if selected_powerup_card:
		selected_powerup_card.set_selected(false) 

	selected_powerup_card = card
	selected_powerup_card.set_selected(true)

	GameManager.selected_powerup = card.item_id
