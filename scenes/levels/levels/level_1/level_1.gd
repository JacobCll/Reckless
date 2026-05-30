extends BaseLevel

@onready var spawner1: EntitySpawner = $EntitySpawner1

func _process(_delta):
	$CanvasLayer/HUD/TotalActiveEntitiesLabel.text = "Blue: %d  Red: %d  Green: %d" % [
		 spawner1.get_alive_count("blue"),
		 spawner1.get_alive_count("red"),
		 spawner1.get_alive_count("green")
	 ]

func _setup_spawners() -> void:
	register_spawner(spawner1)

func _on_level_start():
	super()
	
	spawner1.spawn_entity(2, 0.2)
