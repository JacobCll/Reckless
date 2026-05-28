extends BaseLevel

@onready var spawner1: EntitySpawner = $EntitySpawner1

func _setup_spawners() -> void:
	register_spawner(spawner1)
