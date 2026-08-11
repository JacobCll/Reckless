class_name BlueEntityBase
extends RigidBody2D

@export var particles_scene: PackedScene
@export var particle_color := Color("a3c6ec")

signal despawned
signal slashed

var frozen := false

var was_mouse_over := false
var _prev_mouse_pos: Vector2

func _ready() -> void:
	_prev_mouse_pos = get_viewport().get_mouse_position()

func _process(_delta):
	if global_position.x < -200 or global_position.x > 1224 or global_position.y < -200 or global_position.y > 968:
		despawned.emit()
		queue_free()
		return

	# SLASHING LOGIC
	var mouse_pos = get_viewport().get_mouse_position()
	var mouse_over = _is_mouse_over(mouse_pos)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Mouse crossed from outside -> inside
		if mouse_over and !was_mouse_over:
			slash(mouse_pos - _prev_mouse_pos)
	was_mouse_over = mouse_over
	_prev_mouse_pos = mouse_pos

func _is_mouse_over(mouse_pos: Vector2) -> bool:
	var local = to_local(mouse_pos)
	return Geometry2D.is_point_in_polygon(local, $CollisionPolygon2D.polygon)

# modify this in individual entities
func spawn_halves():
	pass

func slash(hit_direction := Vector2.ZERO):
	slashed.emit()

	# show slash particle effects
	var particles = particles_scene.instantiate()
	get_parent().add_child(particles)
	particles.spawn_particles(global_position, particle_color, hit_direction)

	# spawn two halves of the sprite for the slashing visual effect
	spawn_halves()

	queue_free()

func freeze():
	frozen = true
	set_physics_process(false)

func unfreeze():
	frozen = false
	set_physics_process(true)
