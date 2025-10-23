extends MenuBase

@onready var resume_button = $Panel/VBoxContainer/Resume
@onready var settings_button = $Panel/VBoxContainer/Settings
@onready var exit_button = $Panel/VBoxContainer/Exit

func _ready():
	super._ready()
	resume_button.pressed.connect(close)
	settings_button.pressed.connect(func(): print("Settings pressed"))
	exit_button.pressed.connect(func(): get_tree().quit())

func _process(_delta):
	if Input.is_action_just_pressed("pause_menu"):
		toggle()
