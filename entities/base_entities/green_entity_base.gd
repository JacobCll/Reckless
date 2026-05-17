class_name GreenEntityBase
extends RigidBody2D

@export var particles_scene: PackedScene
@export var particle_color := Color("888888ff")

signal despawned
signal slashed
signal smashed

var was_slashed := false
var was_smashed := false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if global_position.x < -200 or global_position.x > 1224 or global_position.y < -200 or global_position.y > 968:
		despawned.emit()
		queue_free()

func _on_mouse_entered():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		slash()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: 
		smash()

# modify this in individual entities
func spawn_halves():
	pass

func slash():
	slashed.emit()
	was_slashed = true
	
	# show slash particle effects
	var particles = particles_scene.instantiate()
	get_parent().add_child(particles)
	particles.spawn_particles(global_position, particle_color)
	
	# spawn two halves of the sprite for the slashing visual effect
	spawn_halves()

	queue_free()

func smash():
	smashed.emit()
	was_smashed = true
	
	# show smash particle effects
	var particles = particles_scene.instantiate()
	get_parent().add_child(particles)
	particles.spawn_particles(global_position, particle_color)
	
	# spawn pieces of entity as a visual effect 
	spawn_halves()
	
	queue_free()
