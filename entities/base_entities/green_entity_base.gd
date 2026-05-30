class_name GreenEntityBase
extends RigidBody2D

@export var particles_scene: PackedScene
@export var particle_color := Color("888888ff")

signal despawned
signal slashed
signal smashed

var was_interacted := false
var was_slashed := false
var was_smashed := false

var was_mouse_over := false

func _process(_delta):
	if was_interacted: return
	
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
	var local := to_local(mouse_pos)
	return Geometry2D.is_point_in_polygon(local, $CollisionPolygon2D.polygon)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed: 
		smash()

# modify this in individual entities
func spawn_halves():
	pass

func slash():
	if was_interacted: return
	was_interacted = true
	was_slashed = true
	
	slashed.emit()
	
	destroy_entity()

func smash():
	if was_interacted: return
	was_interacted = true
	was_smashed = true
		
	smashed.emit()
	
	destroy_entity()
	
func destroy_entity():
	# show smash particle effects
	var particles = particles_scene.instantiate()
	get_parent().add_child(particles)
	particles.spawn_particles(global_position, particle_color)
	
	# spawn pieces of entity as a visual effect 
	spawn_halves()
	
	queue_free()
