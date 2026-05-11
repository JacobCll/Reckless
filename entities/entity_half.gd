extends Sprite2D

var velocity := Vector2.ZERO
var gravity := 1200.0
var rotation_speed := 5.0

func _process(delta):
	velocity.y += gravity * delta
	position += velocity * delta
	rotation += rotation_speed * delta
