class_name PowerupCard
extends Panel

@onready var powerup_name_label := $Name
@onready var owned_count_label := $OwnedCount

var item_id: String
var powerup_name: String
var quantity_owned: int

func _ready() -> void:
	powerup_name_label.text = powerup_name
	owned_count_label.text = "x " + str(quantity_owned)
