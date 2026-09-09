class_name IconFlare
extends Node2D

## Soft additive sparkles that drift up across an icon, matching the main menu logo flare.
## Add as a child of the Control holding the icon; the emitters size themselves to it.

## Fraction of the parent control's size the sparkles are emitted across.
@export var emission_coverage: Vector2 = Vector2(0.75, 0.75)

# Shared across scenes so the flare's soft glow dot is only ever rasterized once.
static var _flare_texture: ImageTexture

var _emitters: Array[CPUParticles2D] = []

func _ready() -> void:
	for child in get_children():
		if child is CPUParticles2D:
			child.texture = get_flare_texture()
			_emitters.append(child)

	var parent := get_parent() as Control
	if parent:
		parent.resized.connect(_fit_to_parent)
		_fit_to_parent()

func _fit_to_parent() -> void:
	var parent := get_parent() as Control
	if parent == null:
		return

	for emitter in _emitters:
		emitter.position = parent.size / 2.0
		emitter.emission_rect_extents = parent.size * emission_coverage / 2.0

static func get_flare_texture() -> ImageTexture:
	if _flare_texture:
		return _flare_texture

	const SIZE := 24
	var image := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var center := Vector2(SIZE, SIZE) / 2.0
	var radius := SIZE / 2.0
	for x in SIZE:
		for y in SIZE:
			var dist := (Vector2(x + 0.5, y + 0.5) - center).length() / radius
			var alpha := clampf(1.0 - dist, 0.0, 1.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha * alpha))

	_flare_texture = ImageTexture.create_from_image(image)
	return _flare_texture
