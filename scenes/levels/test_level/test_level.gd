extends Node

var score := 0

@onready var spawner1: EntitySpawner = $EntitySpawner1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawner1.entity_slashed.connect(_on_entity_slashed)
	spawner1.entity_smashed.connect(_on_entity_smashed)

func _process(delta: float) -> void:
	$TotalActiveEntities.text = "Blue: %d  Red: %d  Green: %d" % [
		 spawner1.get_alive_count("blue"),
		 spawner1.get_alive_count("red"),
		 spawner1.get_alive_count("green")
	 ]

func _on_entity_slashed(entity_type: String) -> void:
	match entity_type:
		"blue":  score += 1
		"green": score -= 5
	$SlashCount.set_new_text(str(score))

func _on_entity_smashed(entity_type: String) -> void:
	match entity_type:
		"red":   score += 1
		"green": score -= 5
	$SlashCount.set_new_text(str(score))
