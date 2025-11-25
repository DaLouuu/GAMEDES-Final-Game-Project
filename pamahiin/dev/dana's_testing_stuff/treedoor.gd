extends Node2D

@export var marking_id: String = ""
@export var is_correct_tree: bool = false

signal correct_knock(tree)
signal wrong_knock(tree)

var player_in_range := false
var garden_state = null

@onready var interact_area = $Area2D
@onready var anim = $AnimationPlayer
@onready var knock_sfx = $AudioStreamPlayer
@onready var prompt = $InteractionPrompt

func _ready():
	add_to_group("treedoor")

	# Connect enter/exit
	interact_area.body_entered.connect(_on_entered)
	interact_area.body_exited.connect(_on_exited)

	prompt.visible = false
	print_debug("treedoor ready: %s (correct=%s)" % [name, str(is_correct_tree)])

	# ---- NEW: Listen for GardenState availability ----
	var zone_a = get_tree().get_first_node_in_group("ZoneAController")
	if zone_a:
		zone_a.garden_state_ready.connect(_on_garden_state_ready)
	else:
		print_debug("No ZoneAController found to connect garden_state_ready")

	# Also try grabbing GC now (in case it already exists)
	_try_fetch_garden_state()


# -----------------------------------------------------
# NEW — callback when ZoneAController attaches GardenState
# -----------------------------------------------------
func _on_garden_state_ready(gs):
	garden_state = gs
	print_debug("GardenState received via signal for %s" % name)


# -----------------------------------------------------
# NEW — attempts to find GardenState from GameController
# -----------------------------------------------------
func _try_fetch_garden_state():
	# 1. Try finding it as a neighbor (Fastest)
	if has_node("../GardenState"):
		garden_state = get_node("../GardenState")
		print_debug("Found neighbor GardenState for %s" % name)
		return

	# 2. Fallback to GameController (Slower)
	var gc = Global.game_controller
	if gc and gc.get("garden_state") != null:
		garden_state = gc.garden_state
		print_debug("GardenState obtained from Global for %s" % name)


func _on_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		prompt.visible = true
		print_debug("player entered interaction area for %s" % name)


func _on_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		prompt.visible = false
		print_debug("player exited interaction area for %s" % name)


func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		_knock()


# -----------------------------------------------------
# KNOCK ENTRY (plays sound, then defers logic)
# -----------------------------------------------------
func _knock():
	if knock_sfx:
		knock_sfx.play()
		print_debug("played knock sfx on %s" % name)

	# DEFER logic one frame
	call_deferred("_process_knock")


# -----------------------------------------------------
# REAL KNOCK LOGIC with retry system
# -----------------------------------------------------
func _process_knock():
	# 1. Try to fetch the state if we don't have it
	if garden_state == null:
		_try_fetch_garden_state()

	# 2. Determine Cicada status safely (without looping forever)
	var cicadas_on: bool = false
	
	if garden_state:
		cicadas_on = garden_state.cicadas_active
	else:
		# FALLBACK: If state is missing, assume Cicadas are OFF.
		# This guarantees the code reaches the "Wrong Knock" logic below.
		print_debug("CRITICAL: GardenState missing on %s. Defaulting to cicadas_on=FALSE." % name)
		cicadas_on = false 

	print_debug("KNOCK debug on %s: is_correct_tree=%s cicadas_on=%s" % [name, str(is_correct_tree), str(cicadas_on)])

	# ----- CORRECT KNOCK -----
	# Only correct if tree is right AND cicadas are buzzing
	if is_correct_tree and cicadas_on:
		anim.play("correct_flash")
		anim.play("shake")
		emit_signal("correct_knock", self)
		return

	# ----- WRONG KNOCK (Spawns Dwende) -----
	# The code will now always reach this part if something is wrong
	anim.play("wrong_flash")
	anim.play("shake")
	emit_signal("wrong_knock", self)

# -----------------------------------------------------
# DEBUG helper
# -----------------------------------------------------
func print_debug(msg: String) -> void:
	var ENABLE_DEBUG := true
	if ENABLE_DEBUG:
		print("[TreeDoor DEBUG] " + msg)
