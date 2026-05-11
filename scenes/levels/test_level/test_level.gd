extends Node

@export var slash_count := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ExamSpriteSpawner.entity_slashed.connect(_on_entity_slashed)
	$BroomSpriteSpawner.entity_slashed.connect(_on_entity_slashed)

func _on_entity_slashed() -> void:
	slash_count += 1
	$SlashCount.set_new_text(str(slash_count))
	
func _on_entity_despawned() -> void:
	$SpawnTimer.start()
