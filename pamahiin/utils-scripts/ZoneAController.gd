extends Node

signal garden_state_ready(state)    # NEW — lets treedoors know GardenState is ready

@export var cicada_timer: Timer
@export var cicada_player: AudioStreamPlayer
@export var duwende_spawner: Node = null

var zone_a_locked := false
var _garden_state_ready := false


func _ready():
	_setup_controller_fallback()
	_connect_treedoors()
	_connect_cicada_timer()
	start_cicadas()


# ---------------------------------------------------------
# GAME CONTROLLER + GARDEN STATE FALLBACK (IMPROVED)
# ---------------------------------------------------------
func _setup_controller_fallback():
	if Global.game_controller != null:
		# GameController exists → try to attach GS
		call_deferred("_retry_attach_garden_state")
		return

	print("ZoneA: No GameController found. Creating fallback.")

	var temp_gc := Node.new()
	temp_gc.name = "TempGameController"
	temp_gc.set("garden_state", null)

	get_tree().root.call_deferred("add_child", temp_gc)
	Global.game_controller = temp_gc

	call_deferred("_retry_attach_garden_state")

func _retry_attach_garden_state():
	if _garden_state_ready:
		return  # Already done

	var gc = Global.game_controller
	if gc == null:
		call_deferred("_retry_attach_garden_state")
		return

	# Find GardenState anywhere
	var gs = get_tree().root.find_child("GardenState", true, false)

	if gs:
		gc.set("garden_state", gs)
		_garden_state_ready = true
		print("ZoneA: GardenState successfully attached.")
		
		# --- FIX: SYNC CICADA STATE ---
		# If the audio is already playing, ensure the State knows it!
		if cicada_player and cicada_player.playing:
			gs.cicadas_active = true
			print("ZoneA: Synced cicadas_active to TRUE")
		# ------------------------------

		emit_signal("garden_state_ready", gs)
	else:
		# Try again next frame
		call_deferred("_retry_attach_garden_state")

# ---------------------------------------------------------
# TREEDOOR SIGNALS
# ---------------------------------------------------------
func _connect_treedoors():
	for td in get_tree().get_nodes_in_group("treedoor"):
		td.correct_knock.connect(_on_correct_knock)
		td.wrong_knock.connect(_on_wrong_knock)


# ---------------------------------------------------------
# TIMER CONNECT
# ---------------------------------------------------------
func _connect_cicada_timer():
	if cicada_timer:
		var cb := Callable(self, "_on_cicada_timer_timeout")
		if not cicada_timer.is_connected("timeout", cb):
			cicada_timer.timeout.connect(cb)


# ---------------------------------------------------------
# CORRECT KNOCK
# ---------------------------------------------------------
func _on_correct_knock(tree):
	if zone_a_locked:
		return

	var gs = _gs()
	if gs:
		gs.found_stick_zone_a = true
		gs.zone_a_completed = true
		gs.total_sticks_collected += 1

	print("ZoneA: CORRECT knock on tree ", tree.name)

	zone_a_locked = true  
	stop_cicadas()

	# TODO: spawn stick item


# ---------------------------------------------------------
# WRONG KNOCK
# ---------------------------------------------------------
func _on_wrong_knock(tree):
	if zone_a_locked:
		print("ZoneA: WRONG knock ignored — zone completed.")
		return

	print("ZoneA: WRONG knock on tree ", tree.name)

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if player.has_method("apply_sanity_damage"):
			player.apply_sanity_damage(5)
		elif player.has_node("sanity_component"):
			player.get_node("sanity_component").take_damage(5)

	# DWENDE SPAWN FIX
	if duwende_spawner and duwende_spawner.has_method("spawn"):
		var dir = Vector2.RIGHT.rotated(randf() * TAU)
		# CHANGED: Increased 12 -> 60 so it doesn't instantly die
		duwende_spawner.spawn(tree.global_position + dir * 60)

# ---------------------------------------------------------
# CICADA CONTROL
# ---------------------------------------------------------
func start_cicadas():
	var gs = _gs()
	if gs:
		gs.cicadas_active = true

	if cicada_player and not cicada_player.playing:
		cicada_player.play()

	if cicada_timer:
		cicada_timer.start()


func stop_cicadas():
	if cicada_timer:
		cicada_timer.stop()

	var gs = _gs()
	if gs:
		gs.cicadas_active = false

	if cicada_player:
		cicada_player.stop()


func _on_cicada_timer_timeout():
	var gs = _gs()

	if gs:
		gs.cicadas_active = !gs.cicadas_active
		if gs.cicadas_active:
			cicada_player.play()
		else:
			cicada_player.stop()
	else:
		if cicada_player.playing:
			cicada_player.stop()
		else:
			cicada_player.play()


# ---------------------------------------------------------
# GET GardenState safely
# ---------------------------------------------------------
func _gs():
	var gc = Global.game_controller
	if gc == null:
		return null
	return gc.get("garden_state")
