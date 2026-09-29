class_name PowerupModal
extends CanvasLayer

@export var powerup_card_scene: PackedScene

@onready var powerup_grid := $Modal/ScrollContainer/MarginContainer/PowerupGrid

var selected_level_path := ""

var selected_powerup_card: PowerupCard = null

func _ready() -> void:
	hide()

# shows the powerup selection for a level, or starts it directly if the level
# doesn't allow powerups
func open(level_number: int, level_path: String) -> void:
	selected_level_path = level_path

	if not GameManager.level_allows_powerups(level_number):
		_clear_powerup_selection()
		_start_selected_level()
		return

	populate_powerups()
	show()

func close() -> void:
	selected_level_path = ""
	_clear_powerup_selection()

	hide()

func _on_start_button_pressed() -> void:
	_start_selected_level()

func _on_cancel_button_pressed() -> void:
	close()

func _start_selected_level() -> void:
	if selected_level_path == "":
		return

	get_tree().paused = false
	LoadingScreen.transition_to(get_tree(), selected_level_path)

func populate_powerups():
	# the cards below are rebuilt from scratch, so any previous pick is gone
	_clear_powerup_selection()

	for child in powerup_grid.get_children():
		child.queue_free()

	for item_id in GameManager.inventory:
		if GameManager.inventory[item_id] <= 0:
			continue
		if not GameManager.item_info.has(item_id):
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
		_clear_powerup_selection()
		return

	if selected_powerup_card:
		selected_powerup_card.set_selected(false)

	selected_powerup_card = card
	selected_powerup_card.set_selected(true)

	GameManager.selected_powerup = card.item_id

func _clear_powerup_selection() -> void:
	selected_powerup_card = null
	GameManager.selected_powerup = ""
