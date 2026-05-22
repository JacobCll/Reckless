class_name EntitySpawner
extends Node2D

# entity signals
signal entity_slashed(entity_type: String)
signal entity_smashed(entity_type: String)
signal entity_despawned(entity_type: String)

# wave signals
signal wave_started(wave_index: int)
signal wave_completed(wave_index: int)
signal all_waves_completed

@export var path: Path2D

## Blue entities
@export_group("Blue Entity")
@export var blue_scenes:    Array[PackedScene]

## Red entities
@export_group("Red Entity")
@export var red_scenes:    Array[PackedScene]

## Green entities
@export_group("Green Entity")
@export var green_scenes:    Array[PackedScene]

## Waves
@export_group("Waves")
@export var waves: Array[WaveData]
@export var delay_between_waves: float = 2.0

var _entries: Array[SpawnEntry] = []
var _current_wave_index: int = -1
var _current_wave: WaveData = null
var _total_spawned_this_wave: int = 0
var _total_killed_this_wave: int = 0
var spawning_enabled = false

class SpawnEntry:
	var scenes: Array[PackedScene]
	var entity_type: String   # "blue" | "red" | "green"
	var weight: float         # relative spawn chance; higher = more likely
	var max_alive: int        # 0 = unlimited
	var alive_count: int = 0

func start() -> void:
	_start_next_wave()

# Build the weighted pool from inspector data
func _build_entries() -> void:
	_entries.clear()
	if _current_wave == null: 
		return
	_add_group(blue_scenes,  "blue",  _current_wave.blue_weight,  _current_wave.blue_max_alive)
	_add_group(red_scenes,   "red",   _current_wave.red_weight,   _current_wave.red_max_alive)
	_add_group(green_scenes, "green", _current_wave.green_weight, _current_wave.green_max_alive)

func _add_group(scenes, type, weight, max_alive):
	if scenes.is_empty() or weight <= 0.0:
		return
		
	var entry := SpawnEntry.new()
	entry.scenes = scenes        # store the full array directly
	entry.entity_type = type
	entry.weight = weight
	entry.max_alive = max_alive
	_entries.append(entry)

# ─── wave logic ──────────────────────────────────────────────────────────────

func _start_next_wave() -> void:
	print("start next wave function ran")
	if waves.is_empty():
		push_warning("EntitySpawner: no waves configured!")
		return
	
	# proceed to next wave index
	_current_wave_index += 1
	if _current_wave_index >= waves.size():
		all_waves_completed.emit()
		print(_current_wave_index, waves.size())
		return

	_current_wave = waves[_current_wave_index]
	_total_spawned_this_wave = 0
	_total_killed_this_wave  = 0
	_build_entries()

	wave_started.emit(_current_wave_index)
	spawning_enabled = true
	_start_spawn_loop()

func _is_wave_complete():
	# all required entities have been killed 
	return _total_killed_this_wave  >= _current_wave.total_to_kill 

func _on_wave_entity_killed():
	_total_killed_this_wave += 1
	if _is_wave_complete():
		_advance_wave()

func _advance_wave() -> void:
	wave_completed.emit(_current_wave_index)
	spawning_enabled = false
	_clear_all_entities()
	
	if _current_wave_index >= waves.size() - 1:
		all_waves_completed.emit()
		return
		
	await get_tree().create_timer(delay_between_waves).timeout
	_start_next_wave()

# ─── spawn logic ───────────────────────────────────────────────────────────────

# automatic spawn loop
func _start_spawn_loop() -> void:
	while spawning_enabled:
		print("spawn loop started")
		if _is_wave_complete(): 
			return
			
		var delay := randf_range(_current_wave.respawn_delay_min, _current_wave.respawn_delay_max)
		await get_tree().create_timer(delay).timeout
		if not spawning_enabled or _is_wave_complete():
			return
		_trigger_spawn()

func _clear_all_entities():
	for child in get_children():
		if child.has_signal("despawned"):
			child.queue_free()
	for entry in _entries:
		entry.alive_count = 0

# spawns entities
# Steps: pick color type to spawn -> pick entity
func _trigger_spawn() -> void:
	var count := randi_range(_current_wave.spawn_count_min, _current_wave.spawn_count_max)
	for i in count:
		if not spawning_enabled or _is_wave_complete():
			break
			
		var entry := _pick_entry()
		if entry == null: 
			break
		
		if _current_wave.burst_spread > 0.0:
			await get_tree().create_timer(_current_wave.burst_spread * i).timeout
			if not spawning_enabled or _is_wave_complete():
				return
		_spawn_from_entry(entry)

# Weighted random color pick
# Selects an array to get an entity
func _pick_entry() -> SpawnEntry:
	var available: Array[SpawnEntry] = _entries.filter(func(e):
		return e.max_alive == 0 or e.alive_count < e.max_alive
	)
	if available.is_empty():
		return null
	var total_weight: float = available.reduce(func(acc, e): return acc + e.weight, 0.0)
	var roll := randf() * total_weight
	var cumulative := 0.0
	for entry in available:
		cumulative += entry.weight
		if roll <= cumulative:
			return entry
	return available.back()

func _spawn_from_entry(entry: SpawnEntry) -> void:
	var scenes: Array[PackedScene] = entry.scenes
	var scene: PackedScene = scenes.pick_random()
	var entity = scene.instantiate()
	add_child(entity)

	# Position along path
	var curve := path.curve
	var t := randf_range(0.0, curve.get_baked_length())
	entity.global_position = to_global(curve.sample_baked(t))

	entry.alive_count += 1
	
	_total_spawned_this_wave += 1

	entity.despawned.connect(_on_despawned.bind(entry))

	match entry.entity_type:
		"blue":
			entity.slashed.connect(_on_slashed.bind(entry))
		"red":
			entity.smashed.connect(_on_smashed.bind(entry))
		"green":
			entity.slashed.connect(_on_slashed.bind(entry))
			entity.smashed.connect(_on_smashed.bind(entry))

	throw_entity(entity)

# Throw UP
func throw_entity(entity: RigidBody2D) -> void:
	var force := randf_range(_current_wave.throw_force_min, _current_wave.throw_force_max)
	var direction := Vector2(randf_range(_current_wave.spread_min, _current_wave.spread_max), -1.0).normalized()
	entity.apply_central_impulse(direction * force)
	entity.angular_velocity = randf_range(_current_wave.spin_min, _current_wave.spin_max)
	entity.gravity_scale = randf_range(_current_wave.gravity_min, _current_wave.gravity_max)

# when the entity goes out of bounds and gets despawned
func _on_despawned(entry: SpawnEntry) -> void:
	entity_despawned.emit(entry.entity_type)
	entry.alive_count -= 1

func _on_slashed(entry: SpawnEntry) -> void:
	entity_slashed.emit(entry.entity_type)
	entry.alive_count -= 1
	_on_wave_entity_killed()
	
func _on_smashed(entry: SpawnEntry) -> void:
	entity_smashed.emit(entry.entity_type)
	entry.alive_count -= 1
	_on_wave_entity_killed()
	
func get_alive_count(entity_type: String) -> int:
	for entry in _entries:
		if entry.entity_type == entity_type:
			return entry.alive_count
	return 0
func get_total_alive() -> int:
	return _entries.reduce(func(acc, e): return acc + e.alive_count, 0)
func get_current_wave_index() -> int:
	return _current_wave_index
