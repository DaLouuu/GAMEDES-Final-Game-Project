extends CanvasLayer

@onready var background = $Background as TextureRect
@onready var foreground = $Foreground as TextureRect
@onready var title_label = $PAMAHIIN_Title as Label
@onready var buttons_container = $ButtonsContainer as VBoxContainer
@onready var button_control = $ButtonsContainer/Control as Control
@onready var play_button = $ButtonsContainer/Control/Play as Button
@onready var cheat_button = $ButtonsContainer/Control/Cheat as Button
@onready var exit_button = $ButtonsContainer/Control/Exit as Button
@onready var cheat_menu_popup = $CheatMenuPopup as TextureRect 
@onready var background_music = $BackgroundMusic as AudioStreamPlayer

# Animation variables
var tween: Tween
var button_scale_normal: Vector2 = Vector2(1.0, 1.0)
var button_scale_hover: Vector2 = Vector2(1.05, 1.05)
var button_scale_press: Vector2 = Vector2(0.95, 0.95)
var fade_overlay: ColorRect

func _ready():
	# Connect button signals
	connect_buttons()
	
	# Initially hide the cheat menu (TextureRect)
	cheat_menu_popup.hide()
	cheat_menu_popup.modulate = Color(1, 1, 1, 0)
	cheat_menu_popup.scale = Vector2(0.9, 0.9)
	
	# Set focus for keyboard/controller navigation
	play_button.grab_focus()
	
	# Set up visual feedback
	setup_button_feedback()
	
	# Create fade overlay but don't add it yet
	fade_overlay = create_fade_overlay() 
	
	# Setup background music
	setup_background_music()
	
	# Optional: Animate menu entrance
	animate_menu_entrance() 

func setup_background_music():
	# Ensure the AudioStreamPlayer exists
	if background_music:
		# Set properties for background music
		background_music.volume_db = -5.0  # Adjust as needed
		background_music.autoplay = true  # Play automatically
		
		# Connect for looping
		background_music.finished.connect(_on_background_music_finished)
		
		# Start playing (in case autoplay doesn't work)
		if not background_music.playing:
			background_music.play()
	else:
		print("Warning: BackgroundMusic node not found")

func _on_background_music_finished():
	# Loop the music when it ends
	if background_music:
		background_music.play()

func create_fade_overlay() -> ColorRect:
	var overlay = ColorRect.new()
	overlay.name = "FadeOverlay"
	overlay.color = Color.BLACK
	overlay.modulate = Color(1, 1, 1, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.z_index = 1000  # Very high to be on top of everything
	overlay.hide()
	return overlay

func connect_buttons():
	play_button.pressed.connect(_on_play_pressed)
	cheat_button.pressed.connect(_on_cheat_menu_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func setup_button_feedback():
	# Add hover effects
	var main_buttons = [play_button, cheat_button, exit_button]
	for button in main_buttons:
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_unhover.bind(button))
		button.focus_entered.connect(_on_button_focus_entered.bind(button))
		button.focus_exited.connect(_on_button_focus_exited.bind(button))

func animate_menu_entrance():
	# Hide buttons initially
	var buttons = [play_button, cheat_button, exit_button]
	
	for button in buttons:
		button.modulate = Color(1, 1, 1, 0)
		button.scale = Vector2(0.8, 0.8)
	
	# Hide title initially too
	title_label.modulate = Color(1, 1, 1, 0)
	title_label.scale = Vector2(1.2, 1.2)
	
	# Create staggered entrance animation
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	
	# Animate title first
	tween.tween_property(title_label, "modulate:a", 1.0, 0.5)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.5)\
		.set_trans(Tween.TRANS_BACK)
	
	# Then animate buttons with delay
	for i in range(buttons.size()):
		var button = buttons[i]
		tween.tween_property(button, "modulate:a", 1.0, 0.3)\
			.set_delay(0.3 + i * 0.1)\
			.set_trans(Tween.TRANS_SINE)
		tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.3)\
			.set_delay(0.3 + i * 0.1)\
			.set_trans(Tween.TRANS_BACK)

# Button signal handlers
func _on_play_pressed():
	print("Play button pressed!")
	animate_button_press(play_button)
	
	# Fade out music before changing scene
	fade_out_music(1.0)
	await get_tree().create_timer(1.0).timeout
	
	# Wait a moment for animation, then transition
	await get_tree().create_timer(0.2).timeout
	
	Global.game_controller.triggerStart()
	self.queue_free()
func _on_cheat_menu_pressed():
	print("Cheat menu button pressed!")
	animate_button_press(cheat_button)
	show_cheat_menu()

func _on_exit_pressed():
	print("Exit button pressed!")
	animate_button_press(exit_button)
	
	# Disable all buttons
	set_main_menu_buttons_enabled(false)
	
	# Fade out music before quitting
	fade_out_music(1.5)
	
	# Add and show fade overlay
	add_child(fade_overlay)
	fade_overlay.show()
	fade_overlay.modulate = Color(1, 1, 1, 0)
	
	# Bring to front
	move_child(fade_overlay, get_child_count() - 1)
	
	# Animate fade to black (in parallel with music fade)
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.5)\
		.set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	
	# Short pause
	await get_tree().create_timer(0.3).timeout
	
	get_tree().quit()

func fade_out_music(duration: float = 1.0):
	# Only fade if music is playing
	if background_music and background_music.playing:
		var fade_tween = create_tween()
		fade_tween.tween_property(background_music, "volume_db", -80.0, duration)\
			.set_trans(Tween.TRANS_SINE)
		await fade_tween.finished
		background_music.stop()
		# Reset volume for next time (if returning to menu)
		background_music.volume_db = 0.0

# Cheat Menu Methods
func show_cheat_menu():
	# Disable main menu buttons while cheat menu is open
	set_main_menu_buttons_enabled(false)
	
	# Show and animate the cheat menu popup
	cheat_menu_popup.show()
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(cheat_menu_popup, "modulate:a", 1.0, 0.3)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(cheat_menu_popup, "scale", Vector2(1.0, 1.0), 0.3)\
		.set_trans(Tween.TRANS_BACK)
	
	# Wait for animation then set focus to first cheat option
	await tween.finished
	var first_cheat_option = cheat_menu_popup.get_node("CheatButtonsContainer/Control/CheatOption1") as Button
	if first_cheat_option:
		first_cheat_option.grab_focus()

func hide_cheat_menu():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(cheat_menu_popup, "modulate:a", 0.0, 0.2)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(cheat_menu_popup, "scale", Vector2(0.9, 0.9), 0.2)\
		.set_trans(Tween.TRANS_BACK)
	
	await tween.finished
	cheat_menu_popup.hide()
	
	# Re-enable main menu buttons
	set_main_menu_buttons_enabled(true)
	
	# Return focus to cheat button
	cheat_button.grab_focus()

func set_main_menu_buttons_enabled(enabled: bool):
	play_button.disabled = not enabled
	cheat_button.disabled = not enabled
	exit_button.disabled = not enabled
	
	# Visual feedback for disabled state
	var buttons = [play_button, cheat_button, exit_button]
	for button in buttons:
		if enabled:
			button.modulate = Color(1, 1, 1, 1)
		else:
			button.modulate = Color(1, 1, 1, 0.5)

# Visual feedback methods
func _on_button_hover(button: Button):
	if button.disabled or button.has_focus():
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", button_scale_hover, 0.15)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1.1, 1.1, 1.0), 0.15)

func _on_button_unhover(button: Button):
	if button.disabled or button.has_focus():
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", button_scale_normal, 0.15)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0), 0.15)

func _on_button_focus_entered(button: Button):
	if button.disabled:
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", button_scale_hover, 0.15)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1.2, 1.2, 1.0), 0.15)

func _on_button_focus_exited(button: Button):
	if button.disabled:
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", button_scale_normal, 0.15)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0), 0.15)

func animate_button_press(button: Button):
	if button.disabled:
		return
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(button, "scale", button_scale_press, 0.1)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(0.9, 0.9, 0.9), 0.1)
	
	tween.chain().tween_property(button, "scale", button_scale_hover, 0.1)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button, "modulate", Color(1.0, 1.0, 1.0), 0.1)

# Handle keyboard/controller input
func _input(event):
	# Close cheat menu with Escape when it's visible
	if event.is_action_pressed("ui_cancel") and cheat_menu_popup.visible:
		hide_cheat_menu()
		get_viewport().set_input_as_handled()
	
	# Navigate main menu with arrow keys (only when cheat menu is hidden)
	if not cheat_menu_popup.visible:
		var current_focus = get_viewport().gui_get_focus_owner()
		if current_focus and current_focus is Button and current_focus in [play_button, cheat_button, exit_button]:
			if event.is_action_pressed("ui_down"):
				var buttons = [play_button, cheat_button, exit_button]
				var current_index = buttons.find(current_focus)
				var next_index = wrapi(current_index + 1, 0, buttons.size())
				buttons[next_index].grab_focus()
				get_viewport().set_input_as_handled()
			
			elif event.is_action_pressed("ui_up"):
				var buttons = [play_button, cheat_button, exit_button]
				var current_index = buttons.find(current_focus)
				var next_index = wrapi(current_index - 1, 0, buttons.size())
				buttons[next_index].grab_focus()
				get_viewport().set_input_as_handled()

# Public method to close cheat menu from cheat menu script
func close_cheat_menu():
	hide_cheat_menu()

# For scene transitions
func transition_to_scene(scene_path: String):
	var transition_time = 0.5
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(title_label, "modulate:a", 0.0, transition_time/2)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(button_control, "modulate:a", 0.0, transition_time/2)\
		.set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	get_tree().change_scene_to_file(scene_path)
