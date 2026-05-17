extends GPUParticles2D

func spawn_particles(pos: Vector2, color: Color):
	global_position = pos
	emitting = true
	
	# change color
	var mat = process_material as ParticleProcessMaterial
	mat.color = color
