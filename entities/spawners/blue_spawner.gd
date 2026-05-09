extends Node2D

@export var blue_scene: PackedScene
@export var throw_force := 900.0

func spawn_entity(on_slashed, on_despawned):
	var blue_entity = blue_scene.instantiate()
	add_child(blue_entity)
	
	blue_entity.global_position = global_position
	blue_entity.slashed.connect(on_slashed)
	blue_entity.despawned.connect(on_despawned)
	
	throw_up(blue_entity)
	
func throw_up(entity):
	var direction = Vector2.UP
	entity.apply_central_impulse(direction * throw_force)
