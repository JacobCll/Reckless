extends BlueEntityBase

@onready var top_piece_polygon: Polygon2D = $SlashPolygons/TopPiece
@onready var bottom_piece_polygon: Polygon2D = $SlashPolygons/BottomPiece

func spawn_halves():
	var left_impulse = Vector2(
		randf_range(-300, -150),
		randf_range(-500, -300)
	)
	var right_impulse = Vector2(
		randf_range(150, 300),
		randf_range(-500, -300)
	)

	$EntitySpriteHalves.spawn_half_polygon(top_piece_polygon, left_impulse)
	$EntitySpriteHalves.spawn_half_polygon(bottom_piece_polygon, right_impulse)
