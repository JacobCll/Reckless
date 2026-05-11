extends Node2D

signal entity_slashed

@export var blue_scene: PackedScene
@export var throw_force := 900.0
@export var respawn_delay := 0.1

func _ready() -> void:
	spawn_entity()

func spawn_entity():
	var blue_entity = blue_scene.instantiate()
	add_child(blue_entity)
	
	blue_entity.global_position = global_position
	
	blue_entity.slashed.connect(_on_entity_slashed)
	blue_entity.despawned.connect(_on_entity_removed)
	
	throw_up(blue_entity)
	
func throw_up(entity):
	var direction = Vector2.UP
	entity.apply_central_impulse(direction * throw_force)
	
func _on_entity_removed():
	await get_tree().create_timer(respawn_delay).timeout
	spawn_entity()
	
func _on_entity_slashed():
	entity_slashed.emit()
	
	await get_tree().create_timer(respawn_delay).timeout
	spawn_entity()
	
