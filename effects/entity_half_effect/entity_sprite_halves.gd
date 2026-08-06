# This spawns the individual parts of the entity for visual effects
extends Node2D

@export var entity_half_scene: PackedScene
@export var entity_half_polygon_scene: PackedScene

# spawn a whole-texture half for the slashing visual effect
func spawn_half(texture: Texture2D, impulse: Vector2):
	var half = entity_half_scene.instantiate()
	half.texture = texture
	_place_half(half, impulse)

# spawn a half clipped to an arbitrary (non-rectangular) region of a shared
# texture. `template` is a Polygon2D whose polygon/uv/texture are hand-traced
# in the editor (Polygon2D UV tool) over the slashed/smashed state image.
func spawn_half_polygon(template: Polygon2D, impulse: Vector2):
	var half = entity_half_polygon_scene.instantiate()
	var tex_size = template.texture.get_size()

	half.texture = template.texture
	half.uv = template.uv if template.uv.size() > 0 else template.polygon
	half.polygon = _center_on_texture(template.polygon, tex_size)

	_place_half(half, impulse)

func _center_on_texture(polygon: PackedVector2Array, tex_size: Vector2) -> PackedVector2Array:
	var centered := PackedVector2Array()
	for point in polygon:
		centered.append(point - tex_size / 2.0)
	return centered

func _place_half(half: Node2D, impulse: Vector2) -> void:
	var sprite_2d = get_parent().get_node("Sprite2D")

	get_parent().get_parent().add_child(half)

	half.global_position = sprite_2d.global_position
	half.global_rotation = sprite_2d.global_rotation
	half.scale = sprite_2d.scale * randf_range(0.7, 1.1)
	half.velocity = impulse
