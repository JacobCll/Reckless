extends BaseLevel

func _process(_delta):
	$CanvasLayer/HUD/TotalActiveEntitiesLabel.text = "Blue: %d  Red: %d  Green: %d" % [
		 get_total_active_entities("blue"),
		 get_total_active_entities("red"),
		 get_total_active_entities("green")
	 ]
	
func get_total_active_entities(type: String):
	var total_alive = 0
	for spawner in wave_manager.active_spawners:
		total_alive += spawner.get_alive_count(type)
	return total_alive
