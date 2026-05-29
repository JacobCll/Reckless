extends BaseLevel

@onready var spawner1: EntitySpawner = $EntitySpawner1

func _setup_spawners() -> void:
	register_spawner(spawner1)

func _on_level_start():
	super()
	
	spawner1.spawn_entity(2, 0.2)
