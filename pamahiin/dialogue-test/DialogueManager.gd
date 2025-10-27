extends Node

var current_dialogue: Array = [] 
var current_index := 0 
var is_dialogue_active := false 

@onready var dialogue_box = $DialogueBox
@onready var dialogue_label = $DialogueBox/DialogueLabel
@onready var next_timer = $DialogueBox/NextTimer

func _ready():
	dialogue_box.visible = false
	EventBus.player_greeted.connect(show_gate_dialogue)

func show_dialogue(dialogue_lines: Array):
	if is_dialogue_active:
		return
		
	current_dialogue = dialogue_lines
	current_index = 0
	is_dialogue_active = true
	dialogue_box.visible = true
	show_next_line()

func show_next_line():
	if current_index >= current_dialogue.size():
		end_dialogue()
		return
	
	dialogue_label.text = current_dialogue[current_index]
	current_index += 1
	next_timer.start(3.0)  # Auto-advance after 3 seconds

func end_dialogue():
	is_dialogue_active = false
	dialogue_box.visible = false
	current_dialogue.clear()

func show_gate_dialogue():
	var gate_dialogue = [
		"Humingi ka ng paumanhin...bago ka pumasok.",
		"Player: 'Tabi-tabi po. |--| meant no offense.'",
        "*A faint chime echoes*"
	]
	show_dialogue(gate_dialogue)

func _on_NextTimer_timeout():
	show_next_line()

# Quick test function
func test_candle_dialogue(is_correct: bool):
	if is_correct:
		show_dialogue([
			"Inspect Pure Candle: 'Untouched wick. No soot. Smells almost like flowers.'",
            "*You carefully take the candle*"
		])
	else:
		show_dialogue([
			"Inspect Used Candle: 'Dripped wax...edges scorched. Someone prayed with this.'",
			"Entity: 'Huwag mo akong iuwi...'",
            "*A distant sob echoes*"
		])
