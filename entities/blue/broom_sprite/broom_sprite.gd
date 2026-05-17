extends BlueEntityBase

@export var left_half_texture: Texture2D
@export var right_half_texture: Texture2D

func _ready() -> void:
	particle_color = Color("#808080")

func spawn_halves():
	$EntitySpriteHalves.spawn_half(left_half_texture, Vector2(-200, -400))
	$EntitySpriteHalves.spawn_half(right_half_texture, Vector2(200, -400))
