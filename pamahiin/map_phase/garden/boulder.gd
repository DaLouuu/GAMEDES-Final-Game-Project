extends Node2D

func _ready():
	# Wait for GardenState to be ready
	var gs = get_tree().get_first_node_in_group("GardenState")
	if gs:
		# Connect to the signal inside GardenState (we might need to add one)
		# Or just check in process for testing
		set_process(true)

func _process(_delta):
	var gs = get_tree().get_first_node_in_group("GardenState")
	if gs:
		if gs.total_sticks_collected >= 5:
			print("All 5 sticks collected! Removing Boulder.")
			queue_free() # Remove the boulder
