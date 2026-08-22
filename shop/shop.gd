class_name Shop
extends Node

@onready var orb_count_label := $PanelContainer/OrbCount
@onready var items_container := $ScrollContainer/VBoxContainer
@onready var buy_sfx_player := $BuySfxPlayer

@export var shop_item_scene: PackedScene
@export var shop_music: AudioStream
var buy_sfx := preload("res://sfx/shop_sfx/Buy_1.mp3")

# items to sell
var items := {
	"powerup_shields": {
		"display_name": "Shields",
		"cost": 15,
		"description": "+2 shields"
	},
	"powerup_double_orbs": {
		"display_name": "Double orbs",
		"cost": 50,
		"description": "Higher chance of double orb drops"
	},
	"powerup_no_green": {
		"display_name": "No Green!",
		"cost": 40,
		"description": "Eliminate the chance of green entities spawning",
	}
}

func _process(_delta):
	orb_count_label.text = "Orbs: " + str(GameManager.user_orbs)

func _ready() -> void:
	MouseManager.hide_mouse_trail()
	AudioManager.play_music(shop_music)

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
		
		var item_texture_path = GameManager.item_info[item_id]["texture"]
		var item_texture = load(item_texture_path)
		item.texture_rect.texture = item_texture
		

func buy_item(item_id: String, cost: int) -> bool:
	if GameManager.user_orbs < cost:
		return false
	
	GameManager.user_orbs -= cost
	GameManager.inventory[item_id] += 1
	
	GameManager.save_data()
	
	return true

func play_buy_sfx() -> void:
	buy_sfx_player.stream = buy_sfx
	buy_sfx_player.play()

func _on_back_button_pressed() -> void:
	AudioManager.stop_music()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
