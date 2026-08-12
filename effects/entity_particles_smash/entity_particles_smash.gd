extends EntityParticlesBase

# Shared across every smash-particles instance so it's only ever built once.
static var _dot_texture: ImageTexture

func _get_texture() -> ImageTexture:
	if _dot_texture:
		return _dot_texture

	const SIZE := 16
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for x in SIZE:
		for y in SIZE:
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, 1))

	_dot_texture = ImageTexture.create_from_image(image)
	return _dot_texture
