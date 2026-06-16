class_name RedEntityBase
extends RigidBody2D

@export var particles_scene: PackedScene
@export var particle_color := Color("6f6f6fff")

signal despawned
signal smashed

func _process(_delta):
	if global_position.x < -200 or global_position.x > 1224 or global_position.y < -200 or global_position.y > 968:
		despawned.emit()
		queue_free()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		smash()

# modify this in individual entities
func spawn_halves():
	pass

func smash():
	smashed.emit()
	
	# show smash particle effects
	var particles = particles_scene.instantiate()
	get_parent().add_child(particles)
	particles.spawn_particles(global_position, particle_color)
	
	# spawn pieces of entity as a visual effect 
	spawn_halves()
	
	queue_free()
