extends EntityParticlesBase

# Shared across every slash-particles instance so it's only ever built once.
static var _streak_texture: ImageTexture

func _orient(hit_direction: Vector2) -> void:
	if hit_direction.length_squared() < 0.0001:
		return
	# Fling streaks onward in the direction the blade was moving.
	direction = hit_direction.normalized()

func _get_texture() -> ImageTexture:
	if _streak_texture:
		return _streak_texture

	const WIDTH := 6
	const HEIGHT := 26
	var image := Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	var center := Vector2(WIDTH, HEIGHT) / 2.0
	
	for x in WIDTH:
		for y in HEIGHT:
			var dx := absf(x + 0.5 - center.x) / (WIDTH / 2.0)
			var dy := absf(y + 0.5 - center.y) / (HEIGHT / 2.0)
			var alpha := clampf(1.0 - dx, 0.0, 1.0) * clampf(1.0 - dy, 0.0, 1.0)
			alpha = pow(alpha, 0.6)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))

	_streak_texture = ImageTexture.create_from_image(image)
	return _streak_texture
