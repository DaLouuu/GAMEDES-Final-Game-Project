extends AudioStreamPlayer2D

@export var player:Player

@export var footstep_sfx_map: Dictionary[String, Resource] = {
	"cave_stone": preload("uid://ddty6kh3k1x7p"),
	"salt": preload("uid://qnqi6x0wy5g7"),
	"wood": preload("uid://4xdwy8c4atu4"),
	"carpet": preload("uid://bryk4kumpuid"),
	"grass": preload("uid://dqwal04bj3dqk"),
	"stone": preload("uid://deyrlfjtlv8c3"),
	"tile": preload("uid://cccmwejegywa6"),
	"bone": preload("uid://cfueffcslv628")
}

var tile_maps : TileMap


func play_footsteps():
	attempt_play_footsteps()
	play()
func attempt_play_footsteps() -> void:
	for t in get_tree().get_nodes_in_group("tilemaps"):
		if t is TileMapLayer:
			if t.tile_set.get_custom_data_layer_by_name("footstep_sfx")==-1:
				continue
		
		var tile_position: Vector2i = t.local_to_map(t.to_local(global_position))
		var data : TileData = t.get_cell_tile_data(tile_position)
		
		if data:
			var data_type = data.get_custom_data("footstep_sfx")
			if data_type:
				stream = footstep_sfx_map[ data_type ]

			
