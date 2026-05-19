extends Label

var score := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = str(score)

func set_new_text(new_text: String):
	text = new_text
