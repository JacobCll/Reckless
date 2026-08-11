extends EntityParticlesBase

# Shared across every burst-particles instance so it's only ever built once.
static var _star_texture: ImageTexture

func _spawns_burst_layer() -> bool:
	return false

func _get_texture() -> ImageTexture:
	if _star_texture:
		return _star_texture

	const SIZE := 40
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var center := Vector2(SIZE, SIZE) / 2.0
	var half := SIZE / 2.0
	var rot := sqrt(2.0) / 2.0
	for x in SIZE:
		for y in SIZE:
			var d := Vector2(x + 0.5, y + 0.5) - center
			# Union of an axis diamond and a 45-degree-rotated diamond (a square)
			# makes an 8-point sparkle/star silhouette, flat-filled with a thin soft edge.
			var diamond := (absf(d.x) + absf(d.y)) / half
			var rx := d.x * rot - d.y * rot
			var ry := d.x * rot + d.y * rot
			var square := (absf(rx) + absf(ry)) / half
			var dist := minf(diamond, square)
			var alpha := clampf((1.0 - dist) / 0.12, 0.0, 1.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))

	_star_texture = ImageTexture.create_from_image(image)
	return _star_texture
