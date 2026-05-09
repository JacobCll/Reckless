extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "0"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_new_text(new_text: String):
	text = new_text
