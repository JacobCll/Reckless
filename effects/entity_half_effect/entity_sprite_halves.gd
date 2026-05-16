# This spawns the individual parts of the entity for visual effects
extends Node2D

@export var entity_half_scene: PackedScene

# spawn the two halves for the slashing visual effect
func spawn_half(texture: Texture2D, impulse: Vector2):
	var half = entity_half_scene.instantiate()
	var sprite_2d_pos = get_parent().get_node("Sprite2D").global_position
	var sprite_2d_rotation = get_parent().get_node("Sprite2D").global_rotation
	var sprite_2d_scale = get_parent().get_node("Sprite2D").scale
	
	get_parent().get_parent().add_child(half)
	
	half.texture = texture
	half.global_position = sprite_2d_pos
	half.global_rotation = sprite_2d_rotation
	half.scale = sprite_2d_scale * randf_range(0.7, 1.1)
	half.velocity = impulse
