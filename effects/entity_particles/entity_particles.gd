extends CPUParticles2D

func spawn_particles(pos: Vector2, c: Color):
	global_position = pos
	emitting = true
	
	# change color
	color = c
