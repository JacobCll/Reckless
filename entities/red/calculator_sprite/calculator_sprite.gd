extends RedEntityBase

@export var top_left_piece: Texture2D
@export var top_right_piece: Texture2D
@export var bottom_left_piece: Texture2D
@export var bottom_right_piece: Texture2D

func spawn_halves():
	$EntitySpriteHalves.spawn_half(
		top_left_piece,
		Vector2(
			randf_range(-250, -150),
			randf_range(-500, -300)
		)
	)
	$EntitySpriteHalves.spawn_half(
		top_right_piece,
		Vector2(
			randf_range(150, 250),
			randf_range(-500, -300)
		)
	)
	$EntitySpriteHalves.spawn_half(
		bottom_left_piece,
		Vector2(
			randf_range(-250, -150),
			randf_range(100, 300)
		)
	)
	$EntitySpriteHalves.spawn_half(
		bottom_right_piece,
		Vector2(
			randf_range(150, 250),
			randf_range(100, 300)
		)
	)
