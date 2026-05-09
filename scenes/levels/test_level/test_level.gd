extends Node

@export var entity_scene: PackedScene
@export var slash_count := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BlueSpawner.spawn_entity(_on_entity_slashed, _on_entity_despawned)

func _on_entity_slashed() -> void:
	slash_count += 1
	$SlashCount.set_new_text(str(slash_count))
	$SpawnTimer.start()
	
func _on_entity_despawned() -> void:
	$SpawnTimer.start()

func _on_spawn_timer_timeout() -> void:
	$BlueSpawner.spawn_entity(_on_entity_slashed, _on_entity_despawned)
