extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var text_label: RichTextLabel = $Panel/MarginContainer/RichTextLabel

#var _is_showing: bool = false

func _ready() -> void:
	add_to_group("dialogue_ui")
	hide_text()  # start hidden

func show_text(message: String) -> void:
	print("dialogueUI.show_text called: ", message)
	#if not _is_showing: 
		#_is_showing = true
		#visible = true
		#panel.visible = true
		#text_label.text = message 
	## Always refresh 
	text_label.text = message 
	text_label.visible = true 
	panel.show() 
	show() 

func hide_text() -> void:
	#_is_showing = false
	#text_label.text = ""
	#panel.visible = false
	#visible = false
	text_label.text = "" 
	text_label.visible = false 
	panel.hide() 
	hide() 

func is_showing() -> bool:
	#return _is_showing 
	return panel.visible
