class_name ShopItem
extends Panel

@onready var name_label := $NameLabel
@onready var desc_label := $DescriptionLabel
@onready var cost_label := $CostLabel
@onready var buy_button := $BuyButton

var shop
var item_id: String
var cost: int
