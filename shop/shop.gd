class_name Shop
extends Node

@onready var orb_count_label := $PanelContainer/OrbCount
@onready var items_container := $ScrollContainer/VBoxContainer

@export var shop_item_scene: PackedScene

# items to sell
var items := {
	"powerup_shields": {
		"display_name": "Shields",
		"cost": 15,
		"description": "+2 additional health"
	},
	"powerup_double_orbs": {
		"display_name": "Double Orbs",
		"cost": 50,
		"description": "Higher chance of double orb drops"
	}
}

func _ready() -> void:
	MouseManager.hide_mouse_trail()
	
	for item_id in items.keys():
		var item_data = items[item_id]
	
		var item = shop_item_scene.instantiate()
		items_container.add_child(item)
	
		item.shop = self
		item.item_id = item_id
		item.cost = item_data["cost"]
	
		item.name_label.text = item_data["display_name"]
		item.desc_label.text = item_data["description"]
		item.cost_label.text = str(item_data["cost"]) + " orbs"
	
	update_ui()

func buy_item(item_id: String, cost: int) -> bool:
	if GameManager.user_orbs < cost:
		return false

	GameManager.user_orbs -= cost
	GameManager.inventory[item_id] += 1

	GameManager.save_data()
	update_ui()

	return true


func update_ui() -> void:
	orb_count_label.text = "Orbs: " + str(GameManager.user_orbs)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
