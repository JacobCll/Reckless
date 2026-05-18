class_name EntitySpawner
extends Node2D

signal entity_slashed(entity_type: String)
signal entity_smashed(entity_type: String)

@export var path: Path2D

## Blue entities
@export_group("Blue Entity")
@export var blue_scenes:    Array[PackedScene]
@export var blue_weight:    float = 1.0
@export var blue_max_alive: int   = 0   ## 0 = unlimited

## Red entities
@export_group("Red Entity")
@export var red_scenes:    Array[PackedScene]
@export var red_weight:    float = 1.0
@export var red_max_alive: int   = 0

## Green entities
@export_group("Green Entity")
@export var green_scenes:    Array[PackedScene]
@export var green_weight:    float = 1.0
@export var green_max_alive: int   = 0

## Spawn timing
@export_group("Spawn Settings")
@export var respawn_delay_min: float = 0.8
@export var respawn_delay_max: float = 1.2  ## set equal to min for a fixed delay

## Throw physics
@export_group("Throw Settings")
@export var throw_force_min: float = 700.0
@export var throw_force_max: float = 1100.0
@export var spread_min:      float = -0.3
@export var spread_max:      float =  0.3
@export var gravity_min:     float =  0.7
@export var gravity_max:     float =  1.0
@export var spin_min:        float = -5.0
@export var spin_max:        float =  5.0


class SpawnEntry:
	var scenes: Array[PackedScene]
	var entity_type: String   # "blue" | "red" | "green"
	var weight: float         # relative spawn chance; higher = more likely
	var max_alive: int        # 0 = unlimited
	var alive_count: int = 0

var _entries: Array[SpawnEntry] = []

func _ready() -> void:
	_build_entries()
	if not _entries.is_empty():
		_trigger_spawn()

# Build the weighted pool from inspector data
func _build_entries() -> void:
	_entries.clear()
	_add_group(blue_scenes,  "blue",  blue_weight,  blue_max_alive)
	_add_group(red_scenes,   "red",   red_weight,   red_max_alive)
	_add_group(green_scenes, "green", green_weight, green_max_alive)

func _add_group(scenes, type, weight, max_alive):
	if scenes.is_empty() or weight <= 0.0:
		return
		
	var entry := SpawnEntry.new()
	entry.scenes = scenes        # store the full array directly
	entry.entity_type = type
	entry.weight = weight
	entry.max_alive = max_alive
	_entries.append(entry)

func _trigger_spawn() -> void:
	var entry := _pick_entry()
	if entry == null:
		return
	_spawn_from_entry(entry)
	
# Weighted random pick, respecting per-type caps
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

	# Physics
	entity.gravity_scale = randf_range(gravity_min, gravity_max)

	entry.alive_count += 1
	
	entity.despawned.connect(_on_removed.bind(entry))
	
	match entry.entity_type:
		"blue":
			entity.slashed.connect(_on_slashed.bind(entry))
		"red":
			entity.smashed.connect(_on_smashed.bind(entry))
		"green":
			entity.slashed.connect(_on_slashed.bind(entry))
			entity.smashed.connect(_on_smashed.bind(entry))

	throw_entity(entity)
	
func throw_entity(entity: RigidBody2D) -> void:
	var force := randf_range(throw_force_min, throw_force_max)
	var direction := Vector2(randf_range(spread_min, spread_max), -1.0).normalized()
	entity.apply_central_impulse(direction * force)
	entity.angular_velocity = randf_range(spin_min, spin_max)

func _on_removed(entry: SpawnEntry) -> void:
	entry.alive_count -= 1
	_schedule_spawn()

func _on_slashed(entry: SpawnEntry) -> void:
	entity_slashed.emit(entry.entity_type)
	entry.alive_count -= 1
	_schedule_spawn()
	
func _on_smashed(entry: SpawnEntry) -> void:
	entity_smashed.emit(entry.entity_type)
	entry.alive_count -= 1
	_schedule_spawn()

func _schedule_spawn() -> void:
	var delay := randf_range(respawn_delay_min, respawn_delay_max)
	await get_tree().create_timer(delay).timeout
	_trigger_spawn()
