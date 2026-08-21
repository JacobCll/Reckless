extends GreenEntityBase

@onready var top_left_piece_polygon: Polygon2D = $SmashPolygons/TopLeftPiece
@onready var top_right_piece_polygon: Polygon2D = $SmashPolygons/TopRightPiece
@onready var bottom_left_piece_polygon: Polygon2D = $SmashPolygons/BottomLeftPiece
@onready var bottom_right_piece_polygon: Polygon2D = $SmashPolygons/BottomRightPiece

func spawn_halves():
	var halves = $EntitySmashedSpriteHalves if was_smashed else $EntitySlashedSpriteHalves
	halves.spawn_half_polygon(
		top_left_piece_polygon,
		Vector2(
			randf_range(-250, -150),
			randf_range(-500, -300)
		)
	)
	halves.spawn_half_polygon(
		top_right_piece_polygon,
		Vector2(
			randf_range(150, 250),
			randf_range(-500, -300)
		)
	)
	halves.spawn_half_polygon(
		bottom_left_piece_polygon,
		Vector2(
			randf_range(-250, -150),
			randf_range(100, 300)
		)
	)
	halves.spawn_half_polygon(
		bottom_right_piece_polygon,
		Vector2(
			randf_range(150, 250),
			randf_range(100, 300)
		)
	)
