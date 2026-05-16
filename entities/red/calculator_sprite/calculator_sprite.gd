extends RedEntityBase

@export var top_left_piece: Texture2D
@export var top_right_piece: Texture2D
@export var bottom_left_piece: Texture2D
@export var bottom_right_piece: Texture2D

func spawn_halves():
	var sprite_scale = $Sprite2D.scale
	$EntitySpriteHalves.spawn_half(top_left_piece, Vector2(-200, -400))
	$EntitySpriteHalves.spawn_half(top_right_piece, Vector2(200, -400))
	$EntitySpriteHalves.spawn_half(bottom_left_piece, Vector2(-200, 200))
	$EntitySpriteHalves.spawn_half(bottom_right_piece, Vector2(200, 200))
