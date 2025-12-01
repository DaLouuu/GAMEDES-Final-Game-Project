extends AudioStreamPlayer2D

@export var player:Player

@export var footstep_sfx_map: Dictionary[String, Resource] = {
	"cave_stone": preload("uid://ddty6kh3k1x7p"),
	"salt": preload("uid://qnqi6x0wy5g7"),
	"wood": preload("uid://4xdwy8c4atu4"),
	"carpet": preload("uid://bryk4kumpuid"),
	"grass": preload("uid://dqwal04bj3dqk"),
	"stone": preload("uid://deyrlfjtlv8c3"),
	"bone": preload("uid://cfueffcslv628"),
	"tile": preload("uid://cccmwejegywa6"),
	"soil": preload("uid://o5nf5hj0jvn6")
	
}

var tile_maps : TileMap


func play_footsteps():
	attempt_play_footsteps()
func attempt_play_footsteps() -> void:
	player.attempt_play_footsteps()
			
