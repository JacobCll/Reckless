class_name BlueEntityBase
extends RigidBody2D

@export var particles_scene: PackedScene
@export var particle_color := Color("#d4d4d4")

signal despawned
signal slashed

var frozen := false

var was_mouse_over := false

func _process(_delta):
	if global_position.x < -200 or global_position.x > 1224 or global_position.y < -200 or global_position.y > 968:
		despawned.emit()
		queue_free()
		return
	
	# SLASHING LOGIC
	var mouse_over = _is_mouse_over(get_viewport().get_mouse_position())
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Mouse crossed from outside -> inside
		if mouse_over and !was_mouse_over:
			slash()
	was_mouse_over = mouse_over

func _is_mouse_over(mouse_pos: Vector2) -> bool:
	var local = to_local(mouse_pos)
	return Geometry2D.is_point_in_polygon(local, $CollisionPolygon2D.polygon)

# modify this in individual entities
func spawn_halves():
	pass

func slash():
	print("slashed")
	slashed.emit()
	
	# show slash particle effects
	var particles = particles_scene.instantiate()
	get_parent().add_child(particles)
	particles.spawn_particles(global_position, particle_color)
	
	# spawn two halves of the sprite for the slashing visual effect
	spawn_halves()

	queue_free()

func freeze():
	frozen = true
	set_physics_process(false)

func unfreeze():
	frozen = false
	set_physics_process(true)
