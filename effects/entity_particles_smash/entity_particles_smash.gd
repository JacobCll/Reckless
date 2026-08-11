extends EntityParticlesBase

# Shared across every smash-particles instance so it's only ever built once.
static var _dot_texture: ImageTexture

func _get_texture() -> ImageTexture:
	if _dot_texture:
		return _dot_texture

	const SIZE := 16
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var center := Vector2(SIZE, SIZE) / 2.0
	for x in SIZE:
		for y in SIZE:
			var dist := Vector2(x + 0.5, y + 0.5).distance_to(center) / (SIZE / 2.0)
			var alpha := clampf(1.0 - dist, 0.0, 1.0)
			alpha *= alpha
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))

	_dot_texture = ImageTexture.create_from_image(image)
	return _dot_texture
