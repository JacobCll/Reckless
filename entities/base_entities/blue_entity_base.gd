class_name BlueEntityBase
extends RigidBody2D

@export var particles_scene: PackedScene
@export var particle_color := Color("#d4d4d4")

signal despawned
signal slashed

func _ready() -> void:
	$GlowCircle.modulate = Color("53a8f344")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if global_position.x < -200 or global_position.x > 1224 or global_position.y < -200 or global_position.y > 968:
		despawned.emit()
		queue_free()

func _on_mouse_entered():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		slash()

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
