extends Node

const save_location = "user://savestate.json"
	
var _state = {
	"finished_inn": false,
	"finished_church": false,
	"finished_garden": false,
	"finished_graveyard": false,
	"finished_houses": false,
	"finished_sarisari": false,
	"sanity": 100,
	"tile_x": 0,
	"tile_y": 0
}

var state:
	get:
		return _state

func _ready():
	file_load()

func file_load():
	if FileAccess.file_exists(save_location):
		var file = FileAccess.open(save_location, FileAccess.READ)
		_state = file.get_var().duplicate()
		file.close()
	
	print("Game state loaded.")
	
func file_save():
	_signal_save()
	
	var file = FileAccess.open(save_location, FileAccess.WRITE)
	file.store_var(_state.duplicate())
	file.close()

	print("Game state saved.")
	
func _signal_save():
	var save_nodes = get_tree().get_nodes_in_group("saveable")
	for node in save_nodes:
		assert(node.has_method("save"), "A non-saveable node cannot be saved.")
		node.save()
