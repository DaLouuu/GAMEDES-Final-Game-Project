extends TextureRect

# References to cheat menu buttons
@onready var cheat_buttons_container = $CheatButtonsContainer as VBoxContainer
@onready var cheat_button_control = $CheatButtonsContainer/Control as Control
@onready var close_button = $CheatButtonsContainer/Control/CloseButton as Button
@onready var cheat_option_buttons = [
	$CheatButtonsContainer/Control/CheatOption1 as Button,
	$CheatButtonsContainer/Control/CheatOption2 as Button,
	$CheatButtonsContainer/Control/CheatOption3 as Button
]

# Reference to main menu
var main_menu: CanvasLayer
var tween: Tween

func _ready():
	# Get reference to main menu parent
	main_menu = get_parent() as CanvasLayer
	
	# Connect all cheat menu buttons
	connect_cheat_menu_buttons()
	
	# Set up visual feedback for cheat menu buttons
	setup_cheat_button_feedback()

func connect_cheat_menu_buttons():
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	
	# Connect cheat options
	for i in range(cheat_option_buttons.size()):
		var button = cheat_option_buttons[i]
		if button:
			button.pressed.connect(_on_cheat_option_pressed.bind(i))

func setup_cheat_button_feedback():
	# Add hover effects to all cheat menu buttons
	var all_buttons = []
	if close_button:
		all_buttons.append(close_button)
	
	for button in cheat_option_buttons:
		if button:
			all_buttons.append(button)
	
	for button in all_buttons:
		if button:
			button.mouse_entered.connect(_on_cheat_button_hover.bind(button))
			button.mouse_exited.connect(_on_cheat_button_unhover.bind(button))
			button.focus_entered.connect(_on_cheat_button_focus_entered.bind(button))
			button.focus_exited.connect(_on_cheat_button_focus_exited.bind(button))

# Cheat menu button signal handlers
func _on_close_button_pressed():
	print("Close cheat menu button pressed!")
	animate_cheat_button_press(close_button)
	
	# Close the cheat menu
	if main_menu and main_menu.has_method("close_cheat_menu"):
		await get_tree().create_timer(0.2).timeout
		main_menu.close_cheat_menu()

func _on_cheat_option_pressed(option_index: int):
	if option_index < 0 or option_index >= cheat_option_buttons.size():
		return
	
	var button = cheat_option_buttons[option_index]
	if not button:
		return
	
	print("Cheat option %d activated!" % (option_index + 1))
	animate_cheat_button_press(button)
	
	# Implement your cheat functionality here
	match option_index:
		0:
			# Cheat 1: Example 
			print("Infinite Health cheat activated!")
		1:
			# Cheat 2: Example
			print("Teleport cheat activated!")
		2:
			# Cheat 3: Example 
			print("Immunity cheat activated!")
	
	# Optional: Close cheat menu after selecting an option
	await get_tree().create_timer(0.3).timeout
	if main_menu and main_menu.has_method("close_cheat_menu"):
		main_menu.close_cheat_menu()

# Visual feedback for cheat menu buttons
func _on_cheat_button_hover(button: Button):
	if button.disabled or button.has_focus():
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.15)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1.1, 1.1, 1.0), 0.15)

func _on_cheat_button_unhover(button: Button):
	if button.disabled or button.has_focus():
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.15)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0), 0.15)

func _on_cheat_button_focus_entered(button: Button):
	if button.disabled:
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.15)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.0), 0.15)

func _on_cheat_button_focus_exited(button: Button):
	if button.disabled:
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.15)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0), 0.15)

func animate_cheat_button_press(button: Button):
	if button.disabled:
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.1)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(0.9, 0.9, 0.9), 0.1)
	
	tween.chain().tween_property(button, "scale", Vector2(1.05, 1.05), 0.1)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0), 0.1)

# Handle keyboard navigation within cheat menu
func _input(event):
	# Only process if this cheat menu is visible
	if not visible:
		return
	
	# Navigate cheat menu with arrow keys
	var current_focus = get_viewport().gui_get_focus_owner()
	if current_focus and current_focus is Button:
		var all_cheat_buttons = []
		if close_button:
			all_cheat_buttons.append(close_button)
		
		for button in cheat_option_buttons:
			if button:
				all_cheat_buttons.append(button)
		
		if current_focus in all_cheat_buttons:
			if event.is_action_pressed("ui_down"):
				var current_index = all_cheat_buttons.find(current_focus)
				var next_index = wrapi(current_index + 1, 0, all_cheat_buttons.size())
				all_cheat_buttons[next_index].grab_focus()
				get_viewport().set_input_as_handled()
			
			elif event.is_action_pressed("ui_up"):
				var current_index = all_cheat_buttons.find(current_focus)
				var next_index = wrapi(current_index - 1, 0, all_cheat_buttons.size())
				all_cheat_buttons[next_index].grab_focus()
				get_viewport().set_input_as_handled()
