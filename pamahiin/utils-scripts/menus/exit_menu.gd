extends MenuBase

@onready var resume_button = $CenterContainer/Panel/PanelContainer/VBoxContainer/Resume
@onready var main_menu_button = $CenterContainer/Panel/PanelContainer/VBoxContainer/"Main Menu"
@onready var quit_button = $CenterContainer/Panel/PanelContainer/VBoxContainer/Quit
@onready var volume_slider = $CenterContainer/Panel/PanelContainer/VBoxContainer/VBoxContainer/HSlider

signal resumed
signal main_menu
signal quit_game

func _ready():
	super._ready()  # Important: keeps process active while paused + hides initially

	# Connect signals
	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)

func _on_resume_pressed():
	close()
	emit_signal("resumed")

func _on_main_menu_pressed():
	get_tree().paused = false
	emit_signal("main_menu")

func _on_quit_pressed():
	get_tree().paused = false
	emit_signal("quit_game")
	get_tree().quit()

func _on_volume_changed(value: float):
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(value))

func _process(_delta):
	if Input.is_action_just_pressed("exit_menu"):
		toggle()
