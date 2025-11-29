extends AudioStreamPlayer2D

const MIN_DIST_FROM_PLAYER = 10
const MAX_DIST_FROM_PLAYER = 20
const MIN_WAIT_SEC = 10
const MAX_WAIT_SEC = 100

@onready var timer: Timer = $Timer

func _ready() -> void:
	_schedule_playback()

func _on_timer_timeout() -> void:
	_position_near_player()
	play()
	await finished
	
	_schedule_playback()


func _get_player() -> Player:
	if not is_inside_tree():
		return
	
	var player := get_tree().get_first_node_in_group("Player")
	assert(player != null, "No player in scene!")
	return player

func _position_near_player() -> void:
	var angle := randf() * TAU
	var distance := randf_range(MIN_DIST_FROM_PLAYER, MAX_DIST_FROM_PLAYER)
	var offset := Vector2(cos(angle), sin(angle)) * distance
	
	var player := _get_player()
	global_position = player.global_position + offset

func _schedule_playback() -> void:
	timer.wait_time = randi_range(MIN_WAIT_SEC, MAX_WAIT_SEC)
	timer.start()
