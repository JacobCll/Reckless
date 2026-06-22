class_name LevelMenu
extends TextureRect

@export var level_button: PackedScene
@export var level_menu_music: AudioStream
@export var powerup_card_scene: PackedScene

@onready var powerup_modal := $CanvasLayer/PowerupModal
@onready var powerup_grid := $CanvasLayer/PowerupModal/ScrollContainer/MarginContainer/PowerupGrid

var levels = 10
var selected_level_path := ""

var selected_powerup_card: PowerupCard = null
#
#func _process(delta: float) -> void:
	#print(selected_powerup_card)

func _ready() -> void:
	AudioManager.play_music(level_menu_music)
	GameManager.current_scene = "level_menu"
	MouseManager.hide_mouse_trail()
	
	powerup_modal.hide()
	
	var grid = $LevelGrid
	grid.columns = 5
	
	for i in range(levels):
		var btn = level_button.instantiate()
		
		btn.level_number = i + 1
		btn.text = str(i + 1)
		
		btn.level_path = "res://scenes/levels/levels/level_" + str(i+1) + "/level_" + str(i+1) + ".tscn"
		
		btn.level_selected.connect(_on_level_selected)
		
		# disable if not unlocked 
		if not GameManager.is_level_unlocked(i + 1):
			btn.disabled = true
			btn.mouse_default_cursor_shape = Control.CURSOR_ARROW
		
		grid.add_child(btn)

func _on_level_selected(path) -> void:
	selected_level_path = path
	
	populate_powerups()
	
	powerup_modal.show()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_start_button_pressed() -> void:
	if selected_level_path == "":
		return
		
	var loading = preload("res://loading_screen/loading_screen.tscn").instantiate()
	loading.next_scene_path = selected_level_path
	
	get_tree().root.add_child(loading)
	get_tree().current_scene.queue_free()

func _on_cancel_button_pressed() -> void:
	selected_level_path = ""
	selected_powerup_card = null
	
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
		card.selected.connect(select_powerup)
		
		powerup_grid.add_child(card)

func select_powerup(card: PowerupCard):
	if selected_powerup_card == card:
		card.set_selected(false)
		selected_powerup_card = null
		return
	
	if selected_powerup_card:
		selected_powerup_card.set_selected(false) 

	selected_powerup_card = card
	selected_powerup_card.set_selected(true)

	GameManager.selected_powerup = card.item_id
