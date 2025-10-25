class_name QuickTimeEvent
extends CanvasLayer

signal finished

@export var key: Key
@export_range(1, 1000) var min_inputs = 1
@export_range(1, 1000) var max_inputs = 1

@onready var quick_time_text: Label = $QuickTimeText

var input_count = 0
var target_count = null

func _ready() -> void:
	assert(min_inputs <= max_inputs, "min_inputs should be <= max_inputs.")
	hide()
	
func _unhandled_input(event) -> void:
	if target_count == null:
		return

	if event is InputEventKey:
		if event.keycode == key and event.pressed and not event.is_echo():
			input_count += 1
			
			if input_count >= target_count:
				_stop_event()
				hide()

			get_viewport().set_input_as_handled()

func trigger() -> void:
	_init_event()
	show()
	
func _init_event():
	assert(key != Key.KEY_NONE, "Quicktime key cannot be KEY_NONE.")
	quick_time_text.text = "Press %s!" % OS.get_keycode_string(key)
	
	input_count = 0
	target_count = randi_range(min_inputs, max_inputs)
	
func _stop_event():
	input_count = 0
	target_count = null
	
	finished.emit()
