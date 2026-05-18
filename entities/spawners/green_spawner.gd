extends Node2D

signal entity_slashed
signal entity_smashed

@export var path: Path2D # entities will spawn here
@export var green_entity_scenes: Array[PackedScene]
@export var throw_force := 900.0
@export var respawn_delay := 1.0

func _ready() -> void:
	spawn_entity()

func spawn_entity():
	if green_entity_scenes.is_empty():
		return
		
	var random_scene = green_entity_scenes.pick_random()
	var green_entity = random_scene.instantiate()
	
	add_child(green_entity)
	
	var curve = path.curve
	var length = curve.get_baked_length()
	var offset = randf_range(0.0, length)
	var spawn_pos = to_global(curve.sample_baked(offset))

	green_entity.global_position = spawn_pos
	green_entity.gravity_scale = randf_range(0.7, 1) 
	
	green_entity.slashed.connect(_on_entity_slashed)
	green_entity.smashed.connect(_on_entity_smashed)
	green_entity.despawned.connect(_on_entity_removed)
	
	throw_up(green_entity)
	
func throw_up(entity):
	# Random horizontal angle
	var random_x = randf_range(-0.2, 0.2)
	# upward direction with slight angle
	var direction = Vector2(random_x, -1).normalized()
	# throw force
	entity.apply_central_impulse(direction * throw_force)
	# random spin
	entity.angular_velocity = randf_range(-5.0,5)
	
func _on_entity_removed():
	await get_tree().create_timer(respawn_delay).timeout
	spawn_entity()
	
func _on_entity_slashed():
	entity_slashed.emit()
	await get_tree().create_timer(respawn_delay).timeout
	spawn_entity()
	
func _on_entity_smashed():
	entity_smashed.emit()
	await get_tree().create_timer(respawn_delay).timeout
	spawn_entity()
	
