class_name ShopItem
extends Panel

@onready var name_label := $Name
@onready var desc_label := $Description
@onready var cost_label := $Cost
@onready var buy_button := $BuyButton
@onready var owned_label := $OwnedCount
@onready var texture_rect := $Texture

var shop
var item_id: String
var cost: int

func _process(_delta: float) -> void:
	buy_button.disabled = GameManager.user_orbs < cost
	if GameManager.inventory.has(item_id):
		owned_label.text = "Owned: " + str(GameManager.inventory[item_id])
	else:
		owned_label.text = "Owned: 0"
	
func _on_buy_button_pressed() -> void:
	var success = shop.buy_item(item_id, cost)

	if success:
		print("Successfully bought")
		shop.play_buy_sfx()
	else:
		print("Failed to buy ")
