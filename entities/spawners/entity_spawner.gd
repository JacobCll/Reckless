class_name EntitySpawner
extends Node2D

# entity signals
signal entity_killed(entity_type: String)
signal entity_slashed(entity_type: String)
signal entity_smashed(entity_type: String)
signal entity_despawned(entity_type: String) # falls off map

@export var path: Path2D

var current_wave: WaveData

var active := false
var _entity_types: Array[EntityType] = []

class EntityType:
	var scenes: Array[PackedScene]
	var entity_type: String   # "blue" | "red" | "green"
	var weight: float         # relative spawn chance; higher = more likely
	var max_alive: int        # 0 = unlimited
	var alive_count: int = 0

# Build the weighted pool from inspector data
func _build_entity_types() -> void:
	_entity_types.clear()
	if current_wave == null: 
		return
	_add_group(current_wave.blue_scenes,  "blue",  current_wave.blue_weight,  current_wave.blue_max_alive)
	_add_group(current_wave.red_scenes,   "red",   current_wave.red_weight,   current_wave.red_max_alive)
	_add_group(current_wave.green_scenes, "green", current_wave.green_weight, current_wave.green_max_alive)

func _add_group(scenes, type, weight, max_alive):
	if scenes.is_empty() or weight <= 0.0:
		return
		
	var entity_type := EntityType.new()
	entity_type.scenes = scenes        # store the full array directly
	entity_type.entity_type = type
	entity_type.weight = weight
	entity_type.max_alive = max_alive
	_entity_types.append(entity_type)

func start_wave(wave: WaveData) -> void:
	active = true
	current_wave = wave
	_build_entity_types()
	
	_start_spawn_loop()

# stop everything and reset
func stop():
	active = false # Stop any ongoing spawning
	_clear_all_entities() # Clear all spawned entities
	_entity_types.clear() # Clear the entity types pool

# reset all data
func reset() -> void:
	active = false # Stop any ongoing spawning
	_clear_all_entities() # Clear all spawned entities
	_entity_types.clear() # Clear the entity types pool  

# ─── spawn logic ───────────────────────────────────────────────────────────────

# spawn entity
func spawn_entity(n: int = 1, burst_spread: float = 0):
	await get_tree().create_timer(1, false).timeout # delay for 1 second
	for i in n:
		var type := _pick_type() #  pick type
		if type == null: 
			break
			
		await get_tree().create_timer(burst_spread * i, false).timeout
		_spawn_from_type(type, throw_entity_up)

# automatic spawn loop
func _start_spawn_loop() -> void:
	while active:
		var delay := randf_range(current_wave.respawn_delay_min, current_wave.respawn_delay_max)
		await get_tree().create_timer(delay, false).timeout
		if not active:
			return
		_trigger_spawn()

func _clear_all_entities():
	for child in get_children():
		if child.has_signal("despawned"):
			child.queue_free()
	for type in _entity_types:
		type.alive_count = 0

# spawns entities
# Steps: pick color type to spawn -> pick entity
func _trigger_spawn() -> void:
	var count := randi_range(current_wave.spawn_count_min, current_wave.spawn_count_max)
	for i in count:
		if not active:
			break
		
		var type := _pick_type()
		if type == null: 
			break
		
		if current_wave.burst_spread > 0.0:
			await get_tree().create_timer(current_wave.burst_spread * i, false).timeout
			if not active:
				return
		_spawn_from_type(type, throw_entity_up)

# Weighted random color pick
# Selects an entity type
func _pick_type() -> EntityType:
	var available: Array[EntityType] = _entity_types.filter(func(e):
		return e.max_alive == 0 or e.alive_count < e.max_alive
	)
	if available.is_empty():
		return null
	var total_weight: float = available.reduce(func(acc, e): return acc + e.weight, 0.0)
	var roll := randf() * total_weight
	var cumulative := 0.0
	for type in available:
		cumulative += type.weight
		if roll <= cumulative:
			return type
	return available.back()

func _spawn_from_type(type: EntityType, throw_function: Callable) -> void:
	var scenes: Array[PackedScene] = type.scenes
	var scene: PackedScene = scenes.pick_random()
	var entity = scene.instantiate()
	add_child(entity)

	# Position along path
	var curve := path.curve
	var t := randf_range(0.0, curve.get_baked_length())
	entity.global_position = to_global(curve.sample_baked(t))

	type.alive_count += 1

	entity.despawned.connect(_on_despawned.bind(type))

	match type.entity_type:
		"blue":
			entity.slashed.connect(_on_slashed.bind(type))
		"red":
			entity.smashed.connect(_on_smashed.bind(type))
		"green":
			entity.slashed.connect(_on_slashed.bind(type))
			entity.smashed.connect(_on_smashed.bind(type))
	
	# throw up
	throw_function.call(entity)

# Throw UP
func throw_entity_up(entity: RigidBody2D) -> void:
	var force := randf_range(current_wave.throw_force_min, current_wave.throw_force_max)
	var direction := Vector2(randf_range(current_wave.spread_min, current_wave.spread_max), -1.0).normalized()
	entity.angular_velocity = randf_range(current_wave.spin_min, current_wave.spin_max)
	entity.gravity_scale = randf_range(current_wave.gravity_min, current_wave.gravity_max)
	entity.apply_central_impulse(direction * force)

# when the entity goes out of bounds and gets despawned
func _on_despawned(type: EntityType) -> void:
	entity_despawned.emit(type.entity_type)
	type.alive_count -= 1

func _on_slashed(type: EntityType) -> void:
	entity_slashed.emit(type.entity_type)
	entity_killed.emit(type.entity_type)
	type.alive_count -= 1
	
func _on_smashed(type: EntityType) -> void:
	entity_smashed.emit(type.entity_type)
	entity_killed.emit(type.entity_type)
	type.alive_count -= 1

func get_alive_count(entity_type: String) -> int:
	for type in _entity_types:
		if type.entity_type == entity_type:
			return type.alive_count
	return 0
func get_total_alive() -> int:
	return _entity_types.reduce(func(acc, e): return acc + e.alive_count, 0)
