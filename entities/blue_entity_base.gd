class_name BlueEntityBase
extends RigidBody2D

signal despawned
signal slashed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if position.y > 1000 or position.y < -400 or position.x < -200 or position.x > 1200:
		despawned.emit()
		queue_free()

func _on_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		slash()

# modify this in individual entities
func spawn_halves():
	pass

func slash():
	slashed.emit()
	
	# spawn two halves of the sprite for the slashing visual effect
	spawn_halves()

	queue_free()
