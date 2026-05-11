extends Node2D

@export var entity_half_scene: PackedScene

# spawn the two halves for the slashing visual effect
func spawn_half(texture: Texture2D, position: Vector2, impulse: Vector2):
	var half = entity_half_scene.instantiate()

	get_parent().get_parent().add_child(half)
	
	half.velocity = impulse
	half.global_position = position
	half.texture = texture
	half.scale = Vector2(0.15, 0.15)
