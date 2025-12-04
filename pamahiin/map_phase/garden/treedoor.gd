extends Node2D

@export var marking_id: String = ""        # ex: "wind", "spiral"
var is_correct_tree: bool = false

signal correct_knock(tree)
signal wrong_knock(tree)

var player_in_range: bool = false
var garden_state: Node = null

@onready var interact_area: Area2D = $Area2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var knock_sfx: AudioStreamPlayer = $AudioStreamPlayer
@onready var prompt: CanvasItem = $InteractionPrompt
var trunk_sprite: Sprite2D = null

# WHISPER DIALOGUE FILE
var WHISPER_DIALOGUE := load("res://map_phase/garden/Dialogue/garden_whispers.dialogue")


func _ready() -> void:
	add_to_group("treedoor")

	interact_area.body_entered.connect(_on_entered)
	interact_area.body_exited.connect(_on_exited)
	prompt.visible = false

	if has_node("Trunk"):
		trunk_sprite = $Trunk

	# Listen for GardenState (ZoneA emits this)
	var zone_a: Node = get_tree().get_first_node_in_group("ZoneAController")
	if zone_a:
		zone_a.garden_state_ready.connect(_on_garden_state_ready)

	_try_fetch_garden_state()


func _on_garden_state_ready(gs: Node) -> void:
	garden_state = gs
	_connect_garden_state_signals()


func _try_fetch_garden_state() -> void:
	var gc := Global.game_controller
	if gc and gc.get("garden_state") != null:
		garden_state = gc.get("garden_state")
		_connect_garden_state_signals()


func _connect_garden_state_signals() -> void:
	if garden_state == null:
		return

	if garden_state.has_signal("correct_trees_changed"):
		if not garden_state.correct_trees_changed.is_connected(_on_correct_markings_changed):
			garden_state.correct_trees_changed.connect(_on_correct_markings_changed)
			
			if garden_state.get("correct_tree_markings") != null:
				_on_correct_markings_changed(garden_state.correct_tree_markings)

	if garden_state.has_signal("trunk_swap_triggered"):
		if not garden_state.trunk_swap_triggered.is_connected(_on_trunk_swap_triggered):
			garden_state.trunk_swap_triggered.connect(_on_trunk_swap_triggered)


func _on_correct_markings_changed(new_set: Array) -> void:
	is_correct_tree = marking_id.strip_edges() in new_set


func set_is_correct_tree(val: bool) -> void:
	is_correct_tree = val


# ---------------------------------------------------------
# INTERACTION
# ---------------------------------------------------------
func _on_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		prompt.visible = true

func _on_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
		prompt.visible = false

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		_knock()


# ---------------------------------------------------------
# KNOCK LOGIC (FIXED)
# ---------------------------------------------------------
func _knock() -> void:
	if knock_sfx:
		knock_sfx.play()
	call_deferred("_process_knock")


func _process_knock() -> void:
	if garden_state == null:
		_try_fetch_garden_state()

	var cicadas_on: bool = false
	var current_list: Array = []
	
	if garden_state:
		cicadas_on = bool(garden_state.cicadas_active)
		
		# --- FIX: LIVE CHECK --- 
		# Grab the list NOW to be absolutely sure we have the latest data
		if garden_state.get("correct_tree_markings") != null:
			current_list = garden_state.correct_tree_markings
			# Force update status using the live list and stripping whitespace
			is_correct_tree = marking_id.strip_edges() in current_list

	# --- DEBUG LOG ---
	print("Knocking on [%s]. Correct? %s | Cicadas? %s | List: %s" % [marking_id, is_correct_tree, cicadas_on, current_list])

	# ---------------------------------------------------------
	# CORRECT KNOCK
	# ---------------------------------------------------------
	if is_correct_tree and cicadas_on:
		await _play_correct_whisper()

		if anim:
			anim.play("correct_flash")
			anim.play("shake")

		emit_signal("correct_knock", self)
		return

	# ---------------------------------------------------------
	# WRONG KNOCK
	# ---------------------------------------------------------
	await _play_wrong_whisper()

	if anim:
		anim.play("wrong_flash")
		anim.play("shake")

	emit_signal("wrong_knock", self)


# ---------------------------------------------------------
# WHISPERS & SWAP
# ---------------------------------------------------------
func _play_correct_whisper() -> void:
	if WHISPER_DIALOGUE == null: return
	var branch_name: String = "correct_%s" % marking_id
	DialogueManager.show_dialogue_balloon(WHISPER_DIALOGUE, branch_name)
	await DialogueManager.dialogue_ended

func _play_wrong_whisper() -> void:
	if garden_state == null: return
	if WHISPER_DIALOGUE == null: return
	var mistakes: int = 0
	if garden_state.has("mistake_count"):
		mistakes = int(garden_state.mistake_count)
	var branch: String = "wrong_tier_1"
	if mistakes >= 4: branch = "wrong_tier_3"
	elif mistakes >= 2: branch = "wrong_tier_2"
	if randi() % 100 < 3: branch = "whisper_special"
	DialogueManager.show_dialogue_balloon(WHISPER_DIALOGUE, branch)
	await DialogueManager.dialogue_ended

func _on_trunk_swap_triggered(_step: int) -> void:
	return

func apply_trunk_texture(tex: Texture2D) -> void:
	if trunk_sprite:
		trunk_sprite.texture = tex
