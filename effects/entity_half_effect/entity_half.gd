extends Sprite2D

var velocity := Vector2.ZERO
var gravity := 1400.0
var rotation_speed: float

func _ready() -> void:
	rotation_speed = randf_range(-3.0, 3.0)
	gravity = randf_range(1200.0, 1600.0)

func _process(_delta):
	velocity.y += gravity * _delta
	velocity.x *= 0.995 # optional slight slowdown
	position += velocity * _delta
	rotation += rotation_speed * _delta
	
	# delete when goes out of bounds
	if global_position.x < -200 or global_position.x > 1224 or global_position.y < -200 or global_position.y > 968:
		queue_free()
