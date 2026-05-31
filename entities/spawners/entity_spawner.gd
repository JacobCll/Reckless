class_name EntitySpawner
extends Node2D

@export var spawner_name := "Spawner 1"

# ─────────────────────────────────────────────
# GLOBAL SPAWN SETTINGS
# ─────────────────────────────────────────────
@export var spawn_delay_min := 1.0
@export var spawn_delay_max := 3.0

@export var spawn_count_min := 1
@export var spawn_count_max := 3

@export var burst_spread := 0.2

@export var throw_force_min := 200.0
@export var throw_force_max := 500.0

@export var spread_min := -0.5
@export var spread_max := 0.5

@export var spin_min := -10.0
@export var spin_max := 10.0

@export var gravity_min := 0.8
@export var gravity_max := 1.2

# ─────────────────────────────────────────────
# ENTITY TYPE CONFIG
# ─────────────────────────────────────────────
class EntityType:
	var scenes: Array[PackedScene]
	var entity_type: String
	var weight: float
	var max_alive: int
	var alive_count := 0

# Exposed inspector groups (replace WaveData)
@export var blue_scenes: Array[PackedScene]
@export var blue_weight := 1.0
@export var blue_max_alive := 0

@export var red_scenes: Array[PackedScene]
@export var red_weight := 1.0
@export var red_max_alive := 0

@export var green_scenes: Array[PackedScene]
@export var green_weight := 1.0
@export var green_max_alive := 0

# ─────────────────────────────────────────────
# ENTITY SIGNALS
# ─────────────────────────────────────────────
signal entity_killed(entity_type: String)
signal entity_slashed(entity_type: String)
signal entity_smashed(entity_type: String)
signal entity_despawned(entity_type: String)

@export var path: Path2D

var active := false
var _entity_types: Array[EntityType] = []

# ─────────────────────────────────────────────
# INIT / CONFIG BUILD
# ─────────────────────────────────────────────

func _ready() -> void:
	_build_entity_types()

func _build_entity_types() -> void:
	_entity_types.clear()

	_add_group(blue_scenes, "blue", blue_weight, blue_max_alive)
	_add_group(red_scenes, "red", red_weight, red_max_alive)
	_add_group(green_scenes, "green", green_weight, green_max_alive)

func _add_group(scenes: Array, type: String, weight: float, max_alive: int) -> void:
	if scenes.is_empty() or weight <= 0.0:
		return

	var entity_type := EntityType.new()
	entity_type.scenes = scenes
	entity_type.entity_type = type
	entity_type.weight = weight
	entity_type.max_alive = max_alive

	_entity_types.append(entity_type)

# ─────────────────────────────────────────────
# LIFECYCLE
# ─────────────────────────────────────────────

func start() -> void:
	active = true
	_start_spawn_loop()

func stop() -> void:
	active = false
	_clear_all_entities()

func reset() -> void:
	stop()
	_build_entity_types()

func _clear_all_entities() -> void:
	for child in get_children():
		if child is Node:
			child.queue_free()

	for type in _entity_types:
		type.alive_count = 0

# ─────────────────────────────────────────────
# SPAWN LOOP
# ─────────────────────────────────────────────
func _start_spawn_loop() -> void:
	while active:
		var delay := randf_range(spawn_delay_min, spawn_delay_max)
		await get_tree().create_timer(delay, false).timeout
		if not active:
			return
		_trigger_spawn()

# manual spawning
func spawn_entity(n: int = 1, b_spread: float = 0):
	await get_tree().create_timer(1, false).timeout # delay for 1 second
	for i in n: # number of entities to spawn
		var type := _pick_type() #  pick type
		if type == null: 
			break
		await get_tree().create_timer(b_spread * i, false).timeout
		_spawn_from_type(type, throw_entity_up)

func _trigger_spawn() -> void:
	var count := randi_range(spawn_count_min, spawn_count_max)

	for i in count:
		if not active:
			break

		var type := _pick_type()
		if type == null:
			break

		if burst_spread > 0.0:
			await get_tree().create_timer(burst_spread * i, false).timeout
			if not active:
				return
		_spawn_from_type(type, throw_entity_up)

# ─────────────────────────────────────────────
# WEIGHTED PICK
# ─────────────────────────────────────────────
func _pick_type() -> EntityType:
	var available := _entity_types.filter(func(e):
		return e.max_alive == 0 or e.alive_count < e.max_alive
	)

	if available.is_empty():
		return null

	var total_weight := 0.0
	for e in available:
		total_weight += e.weight

	var roll := randf() * total_weight
	var cumulative := 0.0

	for e in available:
		cumulative += e.weight
		if roll <= cumulative:
			return e

	return available.back()


# ─────────────────────────────────────────────
# SPAWNING
# ─────────────────────────────────────────────

func _spawn_from_type(type: EntityType, throw_function: Callable) -> void:
	var scene: PackedScene = type.scenes.pick_random()
	var entity = scene.instantiate()

	# spawn on path
	var curve := path.curve
	var offset := randf_range(0.0, curve.get_baked_length())
	entity.position = curve.sample_baked(offset)

	add_child(entity)

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

	throw_function.call(entity)


# ─────────────────────────────────────────────
# PHYSICS THROW
# ─────────────────────────────────────────────
func throw_entity_up(entity: RigidBody2D) -> void:
	var force := randf_range(throw_force_min, throw_force_max)
	var dir := Vector2(randf_range(spread_min, spread_max), -1.0).normalized()

	entity.angular_velocity = randf_range(spin_min, spin_max)
	entity.gravity_scale = randf_range(gravity_min, gravity_max)
	entity.apply_central_impulse(dir * force)


# ─────────────────────────────────────────────
# SIGNAL HANDLERS
# ─────────────────────────────────────────────

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


# ─────────────────────────────────────────────
# DEBUG HELPERS
# ─────────────────────────────────────────────

func get_alive_count(entity_type: String) -> int:
	for type in _entity_types:
		if type.entity_type == entity_type:
			return type.alive_count
	return 0


func get_total_alive() -> int:
	var total := 0
	for e in _entity_types:
		total += e.alive_count
	return total
