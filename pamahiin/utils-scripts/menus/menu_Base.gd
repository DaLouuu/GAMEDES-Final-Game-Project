extends Control
class_name MenuBase

var is_open := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # Keeps menu functional even when paused
	visible = false

func open() -> void:
	is_open = true
	visible = true
	get_tree().paused = true
	print("%s opened" % name)

func close() -> void:
	is_open = false
	visible = false
	get_tree().paused = false
	print("%s closed" % name)

func toggle() -> void:
	if is_open:
		close()
	else:
		open()
