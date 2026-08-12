extends EntityParticlesBase

# Shared across every liquid-particles instance so it's only ever built once.
static var _droplet_texture: ImageTexture

# Liquid is tinted per-entity (water/oil/soap all reuse this scene), unlike the
# other particle effects which stay white - see entity_particles_base.gd.
func spawn_particles(pos: Vector2, c: Color, hit_direction := Vector2.ZERO) -> void:
	color = c
	super.spawn_particles(pos, c, hit_direction)

func _spawns_burst_layer() -> bool:
	return false

func _orient(hit_direction: Vector2) -> void:
	if hit_direction.length_squared() < 0.0001:
		return
	# Splash outward along the direction the blade was moving.
	direction = hit_direction.normalized()

func _get_texture() -> ImageTexture:
	if _droplet_texture:
		return _droplet_texture

	const SIZE := 20
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var center := Vector2(SIZE, SIZE) / 2.0
	var radius := SIZE / 2.0
	for x in SIZE:
		for y in SIZE:
			var dist := (Vector2(x + 0.5, y + 0.5) - center).length() / radius
			var alpha := clampf((1.0 - dist) / 0.3, 0.0, 1.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))

	_droplet_texture = ImageTexture.create_from_image(image)
	return _droplet_texture
