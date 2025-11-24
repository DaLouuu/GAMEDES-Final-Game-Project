extends Area2D

# Audio player and timer (created at runtime)
@onready var whisper_player: AudioStreamPlayer2D = $"AudioStreamPlayer2D"
var whisper_timer: Timer

# Array to store whisper audio files
var whisper_sounds: Array[AudioStream] = []

# Chance for whisper to play (5% chance each check)
@export var whisper_chance: float = 0.05

# Min and max time between checks (in seconds)
@export var min_check_interval: float = 10.0
@export var max_check_interval: float = 20.0

# Volume range for variation (AudioStreamPlayer uses 0-1 range for volume_db)
@export var min_volume_db: float = -10.0
@export var max_volume_db: float = 0.0

func _ready():

	
	# Create Timer node
	whisper_timer = Timer.new()
	whisper_timer.name = "WhisperTimer"
	whisper_timer.wait_time = 10.0
	whisper_timer.autostart = true
	whisper_timer.timeout.connect(_on_whisper_timer_timeout)
	add_child(whisper_timer)
	
	# Load all whisper audio files
	load_whisper_sounds()
	
	# Set initial random interval
	_set_random_timer_interval()

func load_whisper_sounds():
	# Path to your audio assets folder
	var audio_path = "res://art/Audio Assets/"
	
	# Load the three specific whisper files
	var whisper_files = [
		"4.1 - Whisper (Demon).wav",
		"4.2 - Whisper (Ghosts).wav",
		"4.3 - Whisper (Voices).wav"
	]
	
	for file_name in whisper_files:
		var full_path = audio_path + file_name
		var audio_stream = load(full_path)
		
		if audio_stream:
			whisper_sounds.append(audio_stream)
			print("Loaded whisper sound: ", file_name)
		else:
			push_error("Failed to load whisper sound: " + full_path)
	
	if whisper_sounds.is_empty():
		push_warning("No whisper sounds loaded from " + audio_path)
	else:
		print("Total whisper sounds loaded: ", whisper_sounds.size())

func _on_whisper_timer_timeout():
	# Random chance check
	if randf() < whisper_chance:
		play_random_whisper()
	
	# Set next random interval
	_set_random_timer_interval()

func play_random_whisper():
	if whisper_sounds.is_empty():
		print("No whisper sounds available to play")
		return
	# Pick a random whisper sound
	var random_index = randi() % whisper_sounds.size()
	whisper_player.stream = whisper_sounds[random_index]
	
	# Set random volume for variation
	whisper_player.volume_db = randf_range(min_volume_db, max_volume_db)
	
	# Play the sound
	whisper_player.play()
	print("Playing whisper sound #", random_index, " at volume: ", whisper_player.volume_db, "dB")

func _set_random_timer_interval():
	# Set a random interval for next check
	whisper_timer.wait_time = randf_range(min_check_interval, max_check_interval)
	whisper_timer.start()
