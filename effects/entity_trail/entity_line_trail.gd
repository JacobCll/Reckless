extends Line2D

@export var max_length = 20 # Number of points to keep
var queue : Array = []

func _process(_delta):
	# Get the parent's global position
	var pos = get_parent().global_position
	
	queue.push_front(pos) # Add new position at the start
	
	# Cap the trail length
	if queue.size() > max_length:
		queue.pop_back()
	
	# Clear and redraw the line
	clear_points()
	for point in queue:
		add_point(point)
