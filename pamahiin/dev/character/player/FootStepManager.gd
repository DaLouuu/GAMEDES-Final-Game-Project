extends Node

enum Mode { SINGLE, LAYERED }

@export var mode := Mode.LAYERED
@export var footstep_sfx_map: Dictionary[String, Resource] = {
	"cave_stone": preload("uid://ddty6kh3k1x7p"),
	"salt": preload("uid://qnqi6x0wy5g7"),
	"wood": preload("uid://4xdwy8c4atu4"),
	"carpet": preload("uid://bryk4kumpuid"),
	"grass": preload("uid://dqwal04bj3dqk"),
	"stone": preload("uid://deyrlfjtlv8c3"),
	"tile": preload("uid://cccmwejegywa6"),
	"bone": preload("uid://cfueffcslv628"),
	"soil": preload("uid://o5nf5hj0jvn6")
}
@export var player: Player
@export var base_player: AudioStreamPlayer2D   # used in SINGLE mode

var playing_sounds: Dictionary[String, bool] = {}

func play_step(global_pos: Vector2, tile_type: String, sprint_multiplier: float):
	if not footstep_sfx_map.has(tile_type):
		return
	
	match mode:
		Mode.SINGLE:
			_play_single(tile_type, sprint_multiplier)
		Mode.LAYERED:
			_play_layered(tile_type, global_pos, sprint_multiplier)

# -------- SINGLE MODE (one sound only) --------
func _play_single(tile_type: String, sprint_multiplier: float):
	base_player.stream = footstep_sfx_map[tile_type]
	base_player.pitch_scale = sprint_multiplier
	base_player.volume_db = 5.0 if sprint_multiplier > 1.0 else 0
	base_player.play()

# -------- LAYERED MODE (multiple overlapping) --------
func _play_layered(tile_type: String, pos: Vector2, sprint: float):
	if playing_sounds.get(tile_type, false):
		return
	
	var asp := AudioStreamPlayer2D.new()
	asp.stream = footstep_sfx_map[tile_type]
	asp.global_position = pos
	asp.pitch_scale = sprint
	asp.volume_db = 5.0 if sprint > 1.0 else 0
	
	get_tree().root.add_child(asp)
	playing_sounds[tile_type] = true
	#print("Playing " + tile_type)
	asp.finished.connect(func():
		playing_sounds[tile_type] = false
		asp.queue_free())

	asp.play()
