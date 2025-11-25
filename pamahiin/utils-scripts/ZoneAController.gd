extends Node

@export var cicada_timer: Timer
@export var cicada_player: AudioStreamPlayer
@export var duwende_spawner: Node = null   # assign later if needed

func _ready():
	# Connect all trees in group "treedoor"
	for td in get_tree().get_nodes_in_group("treedoor"):
		if td.has_signal("correct_knock"):
			td.correct_knock.connect(_on_correct_knock)
		else:
			push_warning("TreeDoor missing 'correct_knock' signal: %s" % td)

		if td.has_signal("wrong_knock"):
			td.wrong_knock.connect(_on_wrong_knock)
		else:
			push_warning("TreeDoor missing 'wrong_knock' signal: %s" % td)

	# ---- Validate GameController ----
	if Global.game_controller == null:
		push_error("Global.game_controller is NULL. Ensure GameController scene is loaded BEFORE the Garden scene.")
	else:
		if Global.game_controller.garden_state == null:
			push_warning("GameController.garden_state is NULL. Add a GardenState node to the Garden scene.")

	# ---- Connect cicada timer ----
	if cicada_timer:
		var callback := Callable(self, "_on_cicada_timer_timeout")
		if not cicada_timer.is_connected("timeout", callback):
			cicada_timer.timeout.connect(callback)

	start_cicadas()


# -------------------------------------------------------
#   CORRECT KNOCK
# -------------------------------------------------------
func _on_correct_knock(_tree):
	var gc = Global.game_controller
	var gs = (gc.garden_state if gc != null else null)

	if gs != null:
		if gs.found_stick_zone_a:
			return
		gs.found_stick_zone_a = true
		gs.zone_a_completed = true
		gs.total_sticks_collected += 1
	else:
		print("Warning: garden_state not reachable during correct knock.")

	# Stop cicadas
	if cicada_player and cicada_player.playing:
		cicada_player.stop()

	if cicada_timer and not cicada_timer.is_stopped():
		cicada_timer.stop()

	if gs != null:
		gs.cicadas_active = false


# -------------------------------------------------------
#   WRONG KNOCK
# -------------------------------------------------------
func _on_wrong_knock(tree):
	print("WRONG knock on:", tree.marking_id)

	if duwende_spawner and duwende_spawner.has_method("spawn"):
		duwende_spawner.spawn(tree.global_position)
	else:
		print("Duwende spawner not assigned or missing spawn().")


# -------------------------------------------------------
#   CICADA CONTROL
# -------------------------------------------------------
func start_cicadas():
	if cicada_timer:
		cicada_timer.start()

	var gc = Global.game_controller
	if gc != null and gc.garden_state != null:
		gc.garden_state.cicadas_active = true
	elif cicada_player and not cicada_player.playing:
		cicada_player.play()


func stop_cicadas():
	if cicada_timer:
		cicada_timer.stop()

	var gc = Global.game_controller
	if gc != null and gc.garden_state != null:
		gc.garden_state.cicadas_active = false

	if cicada_player and cicada_player.playing:
		cicada_player.stop()


# -------------------------------------------------------
#   TIMER TIMEOUT
# -------------------------------------------------------
func _on_cicada_timer_timeout():
	var gc = Global.game_controller
	var gs = (gc.garden_state if gc != null else null)

	if gs != null:
		gs.cicadas_active = !gs.cicadas_active

		if gs.cicadas_active:
			if cicada_player: cicada_player.play()
		else:
			if cicada_player: cicada_player.stop()
	else:
		# fallback
		if cicada_player:
			if cicada_player.playing:
				cicada_player.stop()
			else:
				cicada_player.play()
