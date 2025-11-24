extends CanvasLayer

signal closed

@onready var label: Label = $PanelContainer/Label

func show_message(text: String):
	label.text = text
	show()

func _unhandled_input(event):
	if event.is_action_pressed("accept") \
	or event.is_action_pressed("interact") \
	or event is InputEventMouseButton and event.pressed:
		close()

func close():
	hide()
	closed.emit()
	queue_free()
