extends Node

var SETTINGS_SAVE_FILE := "user://settings.dat"

var master_volume := 1.0
var music_volume := 1.0
var sfx_volume := 1.0

func _ready():
	load_settings()
	apply_settings()
	
func save():
	var data = {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume
	}
	
	var file = FileAccess.open(SETTINGS_SAVE_FILE, FileAccess.WRITE)
	file.store_var(data)

func load_settings():
	if not FileAccess.file_exists(SETTINGS_SAVE_FILE):
		return
	
	var file = FileAccess.open(SETTINGS_SAVE_FILE, FileAccess.READ)
	var data = file.get_var()
	
	if typeof(data) != TYPE_DICTIONARY:
		return
	
	master_volume = data.get("master_volume", 1.0)
	music_volume = data.get("music_volume", 1.0)
	sfx_volume = data.get("sfx_volume", 1.0)


func apply_settings():
	var master_bus = AudioServer.get_bus_index("Master")
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("Sfx")
	
	AudioServer.set_bus_volume_db(
		master_bus,
		linear_to_db(master_volume)
	)
	
	AudioServer.set_bus_volume_db(
		music_bus,
		linear_to_db(music_volume)
	)

	AudioServer.set_bus_volume_db(
		sfx_bus,
		linear_to_db(sfx_volume)
	)
