extends BlueEntityBase

@export var left_half_texture: Texture2D
@export var right_half_texture: Texture2D

func spawn_halves():
	var left_impulse = Vector2(
		randf_range(-300, -150),
		randf_range(-500, -300)
	)
	var right_impulse = Vector2(
		randf_range(150, 300),
		randf_range(-500, -300)
	)
	$EntitySpriteHalves.spawn_half(left_half_texture, left_impulse)
	$EntitySpriteHalves.spawn_half(right_half_texture, right_impulse)
