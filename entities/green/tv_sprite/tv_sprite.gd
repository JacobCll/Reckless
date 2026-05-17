extends GreenEntityBase

@export var smashed_bottom_left: Texture2D
@export var smashed_upper_left: Texture2D
@export var smashed_right: Texture2D

@export var slashed_left: Texture2D
@export var slashed_right: Texture2D

func spawn_halves():
	if was_slashed:
		var left_impulse = Vector2(
			randf_range(-300, -150),
			randf_range(-500, -300)
		)
		var right_impulse = Vector2(
			randf_range(150, 300),
			randf_range(-500, -300)
		)
		$EntitySlashedSpriteHalves.spawn_half(slashed_left, left_impulse)
		$EntitySlashedSpriteHalves.spawn_half(slashed_right, right_impulse)

	if was_smashed:
		$EntitySmashedSpriteHalves.spawn_half(
			smashed_upper_left,
			Vector2(
				randf_range(-250, -150),
				randf_range(-500, -300)
			)
		)
		$EntitySmashedSpriteHalves.spawn_half(
			smashed_bottom_left,
			Vector2(
				randf_range(-250, -150),
				randf_range(100, 300)
			)
		)
		$EntitySmashedSpriteHalves.spawn_half(
			smashed_right,
			Vector2(
			randf_range(150, 300),
			randf_range(-500, -300)
			)
		)
