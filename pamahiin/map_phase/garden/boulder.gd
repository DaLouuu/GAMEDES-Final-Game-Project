extends Node2D

func _ready():
	# Wait a frame to ensure GardenState is ready, then connect
	call_deferred("_connect_to_garden_state")

func _connect_to_garden_state():
	# Smart Search for the correct GardenState (ignoring ghosts)
	var candidates = get_tree().get_nodes_in_group("GardenState")
	var gs = null
	
	for candidate in candidates:
		if candidate.get("correct_tree_markings") and not candidate.correct_tree_markings.is_empty():
			gs = candidate
			break
	
	# If we found the active state, connect
	if gs:
		if not gs.boulder_unlocked.is_connected(_on_boulder_unlocked):
			gs.boulder_unlocked.connect(_on_boulder_unlocked)
		
		# Safety Check: If we loaded the game and already have 5 sticks, delete immediately
		if gs.total_sticks_collected >= 5:
			queue_free()

func _on_boulder_unlocked():
	# Optional: Play a crumbling sound here
	print("Boulder Removed!")
	queue_free()
