class_name NotificationScreen
extends Control

@onready var message_select_panel = $MessageSelectContainer/MessageSelect/VBoxContainer
@onready var message_content_panel = $MessageContentContainer/MessageContentPanel
@onready var read_full_screen_button = $MessageContentContainer/MessageContentPanel/ReadFullScreenButton

const VIEW_MESSAGE_SCENE := preload("res://notification/viewmessage.tscn")

var current_message_selected := ""

func _ready() -> void:
	MouseManager.hide_mouse_trail()
	
	for message in message_select_panel.get_children():
		if message is LinkButton:
			message.pressed.connect(_on_message_pressed.bind(message))
			
	for content in message_content_panel.get_children():
		if content is RichTextLabel:
			content.hide()
			
	read_full_screen_button.hide()

func _on_message_pressed(message_button: LinkButton) -> void:
	if current_message_selected == message_button.name:
		return
	
	# hide the last message content node
	if current_message_selected != "":
		var previous := message_content_panel.get_node_or_null(current_message_selected + "Content")
		if previous:
			previous.hide()
	
	# replace with new
	current_message_selected = message_button.name
	
	# replace with new content
	var current := message_content_panel.get_node_or_null(current_message_selected + "Content")
	if current:
		current.show()
	
	read_full_screen_button.show()

func _on_read_full_screen_button_pressed() -> void:
	if current_message_selected == "":
		return
	
	var message_content = message_content_panel.get_node_or_null(current_message_selected + "Content")
	if message_content == null:
		return
		
	var view_message_scene = VIEW_MESSAGE_SCENE.instantiate() as ViewMessage
	
	# add to tree first
	get_tree().current_scene.add_child(view_message_scene)
	
	# set text of viewmessage to the message content
	view_message_scene.message_content_label.text = message_content.text
	
	# add date and time
	var message_node = message_select_panel.get_node_or_null(current_message_selected) as MessageLinkButton
	if message_node == null:
		return
	
	view_message_scene.subject_title_label.text = message_node.subject_title
	view_message_scene.date_label.text = message_node.date
	view_message_scene.time_label.text = message_node.time

func _on_back_button_pressed() -> void:
	current_message_selected = ""
	LoadingScreen.transition_to(get_tree(), "res://scenes/main_menu.tscn")
