extends RigidBody2D

signal despawned
signal slashed

@export var left_half_texture: Texture2D
@export var right_half_texture: Texture2D
@export var sprite_half_scene: PackedScene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if position.y > 1000 or position.y < -400 or position.x < -200 or position.x > 1200:
		despawned.emit()
		queue_free()

func _on_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		slash()

func slash():
	slashed.emit()
	
	# spawn two halves of the sprite for the slashing visual effect
	spawn_half(left_half_texture, Vector2(-200, -400))
	spawn_half(right_half_texture, Vector2(200, -400))

	queue_free()

# spawn the two halves for the slashing visual effect
func spawn_half(texture: Texture2D, impulse: Vector2):
	var half = sprite_half_scene.instantiate()

	get_parent().add_child(half)

	half.global_position = global_position
	
	half.velocity = impulse
	
	half.get_node("Half").texture = texture
	half.get_node("Half").scale = Vector2(0.15, 0.15)
