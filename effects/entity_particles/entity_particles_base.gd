class_name EntityParticlesBase
extends CPUParticles2D

# Lazily loaded (not preloaded) since the burst scene's script extends this
# very class - preloading it here at parse time would be a load cycle.
static var _burst_scene: PackedScene

func _ready() -> void:
	texture = _get_texture()
	finished.connect(queue_free)

# hit_direction is the motion that caused the hit (e.g. the slash drag vector).
# Leave at ZERO for hits with no inherent direction, like a smash click.
func spawn_particles(pos: Vector2, c: Color, hit_direction := Vector2.ZERO) -> void:
	global_position = pos
	_orient(hit_direction)

	#color = c

	emitting = true

	if _spawns_burst_layer():
		_spawn_burst_layer(pos, c, hit_direction)

func _spawn_burst_layer(pos: Vector2, c: Color, hit_direction: Vector2) -> void:
	if _burst_scene == null:
		_burst_scene = load("res://effects/entity_particles_burst/entity_particles_burst.tscn")
	var burst = _burst_scene.instantiate()
	get_parent().add_child(burst)
	burst.modulate = modulate
	burst.spawn_particles(pos, c, hit_direction)

# overridden to false by the burst layer itself, so it doesn't spawn another burst on top of itself
func _spawns_burst_layer() -> bool:
	return true

func _orient(_hit_direction: Vector2) -> void:
	pass

func _get_texture() -> ImageTexture:
	return null
