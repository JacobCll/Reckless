class_name ShopItem
extends Panel

@onready var name_label := $Name
@onready var desc_label := $Description
@onready var cost_label := $Cost
@onready var buy_button := $BuyButton
@onready var owned_label := $OwnedCount
@onready var texture_rect := $Texture
@onready var icon_flare := $Texture/IconFlare

var shop
var item_id: String
var cost: int

func _process(_delta: float) -> void:
	var can_afford := GameManager.user_orbs >= cost
	# stays clickable (rather than truly disabled) so an insufficient-funds click
	# still registers and can play the denial sfx below; dimmed to read as disabled
	buy_button.modulate.a = 1.0 if can_afford else 0.5
	buy_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if can_afford else Control.CURSOR_ARROW
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
		shop.play_insufficient_funds_sfx()
