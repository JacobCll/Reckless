extends Node

var SETTINGS_SAVE_FILE := "user://settings.dat"

var music_volume := 1.0
var sfx_volume := 1.0

func _ready():
	load_settings()

func save():
	var data = {
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
	
	music_volume = data.get("music_volume", 1.0)
	sfx_volume = data.get("sfx_volume", 1.0)
