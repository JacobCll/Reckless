extends Node

@export var score := 0

@onready var spawner: EntitySpawner = $EntitySpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawner.entity_slashed.connect(_on_entity_slashed)
	spawner.entity_smashed.connect(_on_entity_smashed)

func _on_entity_slashed(entity_type: String) -> void:
	match entity_type:
		"blue":  score += 1
		"green": score -= 5
	$SlashCount.set_new_text(str(score))

func _on_entity_smashed(entity_type: String) -> void:
	match entity_type:
		"red":   score += 3
		"green": score -= 5
	$SlashCount.set_new_text(str(score))
