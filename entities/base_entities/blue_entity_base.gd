class_name BlueEntityBase
extends RigidBody2D

@export var particles_scene: PackedScene
@export var particle_color := Color("#d4d4d4")

signal despawned
signal slashed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if global_position.x < -200 or global_position.x > 1224 or global_position.y < -200 or global_position.y > 968:
		despawned.emit()
		queue_free()
		return
	
	# Catch fast swipes that skipped _on_mouse_entered
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if _is_mouse_over(get_viewport().get_mouse_position()):
			slash()

func _is_mouse_over(mouse_pos: Vector2) -> bool:
	var local = to_local(mouse_pos)
	return Geometry2D.is_point_in_polygon(local, $CollisionPolygon2D.polygon)

# modify this in individual entities
func spawn_halves():
	pass

func slash():
	slashed.emit()
	
	# show slash particle effects
	var particles = particles_scene.instantiate()
	get_parent().add_child(particles)
	particles.spawn_particles(global_position, particle_color)
	
	# spawn two halves of the sprite for the slashing visual effect
	spawn_halves()

	queue_free()
