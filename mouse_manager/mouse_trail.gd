extends Line2D

@export var max_length := 20

var queue: Array[Vector2] = []

func _process(_delta: float) -> void:
	var pos := get_global_mouse_position()

	queue.push_front(pos)

	if queue.size() > max_length:
		queue.pop_back()

	points = queue
