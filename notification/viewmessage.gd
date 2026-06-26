class_name ViewMessage
extends Control

@onready var message_content_label = $Panel/Message
@onready var subject_title_label = $SubjectTitle
@onready var date_label = $Date
@onready var time_label = $Time

func _on_back_button_pressed() -> void:
	queue_free()
