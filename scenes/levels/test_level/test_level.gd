extends Node

@export var score := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BlueEntitySpawner.entity_slashed.connect(_on_entity_slashed)
	$RedEntitySpawner.entity_smashed.connect(_on_entity_smashed)
	$GreenEntitySpawner.entity_smashed.connect(_on_green_entity_smashed)
	$GreenEntitySpawner.entity_slashed.connect(_on_green_entity_slashed)

# add +1 when blue entity is slashed
func _on_entity_slashed():
	score += 1
	$SlashCount.set_new_text(str(score))

func _on_entity_smashed():
	score += 1
	$SlashCount.set_new_text(str(score))

func _on_green_entity_slashed():
	score -= 5
	$SlashCount.set_new_text(str(score))
	
func _on_green_entity_smashed():
	score -= 5
	$SlashCount.set_new_text(str(score))
