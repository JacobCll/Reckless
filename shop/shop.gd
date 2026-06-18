class_name Shop
extends Node

@onready var orb_count_label := $OrbCountPanel/OrbCount
@onready var items_container := $ScrollContainer/VBoxContainer

@export var shop_item_scene: PackedScene
var items := {
	"shields": {
		"cost": 15,
		"description": "+2 additional health"
	}
}

func _ready() -> void:
	for item_id in items.keys():
		var item_data = items[item_id]

		var item = shop_item_scene.instantiate()
		items_container.add_child(item)

		item.shop = self
		item.item_id = item_id
		item.cost = item_data["cost"]

		item.name_label.text = item_data["display_name"]
		item.desc_label.text = item_data["description"]
		item.cost_label.text = str(item_data["cost"])
	
	update_ui()

func update_ui() -> void:
	orb_count_label.text = "Orbs: " + str(GameManager.user_orbs)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
