extends Node2D

@onready var interact_area: Area2D = $Area2D 

# --- CHANGED: Use @export so you can drag-and-drop the file in the Inspector ---
@export var stick_dialogue_resource: Resource

func _ready():
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node):
	if body.is_in_group("Player"):
		_collect_stick()

func _collect_stick():
	# Smart Search for GardenState
	var candidates = get_tree().get_nodes_in_group("GardenState")
	var gs = null
	for candidate in candidates:
		if candidate.get("correct_tree_markings") and not candidate.correct_tree_markings.is_empty():
			gs = candidate
			break
	
	if gs:
		gs.total_sticks_collected += 1
		var count = gs.total_sticks_collected
		print("Stick collected. Total: ", count)
		
		# Check if the resource was assigned
		if stick_dialogue_resource == null:
			print("ERROR: Please assign 'garden_sticks.dialogue' to StickPickup in the Inspector!")
			queue_free()
			return

		if count < 5:
			var branch = "pickup_%d" % count
			DialogueManager.show_dialogue_balloon(stick_dialogue_resource, branch)
		
		else:
			# Final stick logic
			DialogueManager.show_dialogue_balloon(stick_dialogue_resource, "pickup_final")
			await DialogueManager.dialogue_ended
			
			var controller = get_tree().get_first_node_in_group("ZoneAController")
			if controller:
				controller.shake_camera(5.0, 1.5)
			
			if gs.has_method("trigger_boulder_unlock"):
				gs.trigger_boulder_unlock()
			
	queue_free()
