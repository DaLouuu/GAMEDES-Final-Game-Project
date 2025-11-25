extends Node

@export var cicada_timer: Timer
@export var cicada_player: AudioStreamPlayer2D
@export var duwende_spawner: Node = null   # assign later if needed

func _ready():
	# Connect all trees
	for td in get_tree().get_nodes_in_group("treedoor"):
		td.correct_knock.connect(_on_correct_knock)
		td.wrong_knock.connect(_on_wrong_knock)

	# Start cicadas immediately
	start_cicadas()


# ----- CORRECT KNOCK -----
func _on_correct_knock(tree):
	if Global.GameController.garden_state.found_stick_zone_a:
		return  # already done

	Global.GameController.garden_state.found_stick_zone_a = true
	Global.GameController.garden_state.total_sticks_collected += 1
	Global.GameController.garden_state.zone_a_completed = true

	# Stop cicadas
	Global.GameController.garden_state.cicadas_active = false
	if cicada_player:
		cicada_player.stop()

	# TODO: spawn stick pickup here


# ----- WRONG KNOCK -----
func _on_wrong_knock(tree):
	print("WRONG knock on:", tree.marking_id)

	# TODO: spawn duwende here:
	# if duwende_spawner:
	#	   duwende_spawner.spawn(tree.global_position)


# ----- CICADA TIMING -----
func start_cicadas():
	if cicada_timer:
		cicada_timer.start()


func stop_cicadas():
	if cicada_timer:
		cicada_timer.stop()
	Global.GameController.garden_state.cicadas_active = false


func _on_cicada_timer_timeout():
	# toggle cicadas on/off
	var gs = Global.GameController.garden_state
	gs.cicadas_active = !gs.cicadas_active

	if gs.cicadas_active:
		if cicada_player:
			cicada_player.play()
	else:
		if cicada_player:
			cicada_player.stop()
