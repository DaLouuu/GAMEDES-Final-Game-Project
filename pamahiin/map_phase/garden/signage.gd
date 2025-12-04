extends Node2D

# Unified Signage script
# - Supports tree notes via `marking_id`
# - Supports general signages via `signage_branch`
# - Supports legacy array mode
# - Uses DialogueManager.show_dialogue_balloon

@export var signage_branch: String = ""        # e.g. "gate_signage", "well_signage", "found_signage_1"
@export var marking_id: String = ""            # e.g. "wind", "spiral", "eye", "tally", "hollow"
@export var use_legacy_array: bool = false
@export var dialogue_resources: Array[Resource] = []   # legacy only

@onready var prompt := $InteractionPrompt
@onready var interact_area := $Area2D

var player_in_range: bool = false

func _ready() -> void:
	prompt.visible = false
	interact_area.body_entered.connect(_on_entered)
	interact_area.body_exited.connect(_on_exited)


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
		_interact()


func _interact() -> void:
	# 1) Legacy array mode
	if use_legacy_array and dialogue_resources.size() > 0:
		_handle_legacy_dialogue()
		return

	# 2) World signages (gate, well, boulder, found notes)
	if signage_branch != "":
		var dlg_res := load("res://map_phase/garden/Dialogue/garden_signages.dialogue")
		if dlg_res:
			DialogueManager.show_dialogue_balloon(dlg_res, signage_branch)
			await DialogueManager.dialogue_ended

			# -------------------------
			# SPECIAL CASE: GATE SIGNAGE
			# After reading, the gate opens
			# -------------------------
			if signage_branch == "gate_signage":
				var chase := get_tree().get_first_node_in_group("GardenChaseManager")
				if chase and chase.has_method("open_gate"):
					chase.open_gate()
				else:
					push_warning("Signage: GardenChaseManager not found or open_gate() missing!")

		else:
			push_warning("garden_signages.dialogue not found!")

		return

	# 3) Tree notes (wind, spiral, eye, tally, hollow)
	if marking_id != "":
		var tree_branch := "%s_tree" % marking_id
		var dlg_res2 := load("res://map_phase/garden/Dialogue/garden_signages.dialogue")
		if dlg_res2:
			DialogueManager.show_dialogue_balloon(dlg_res2, tree_branch)
			await DialogueManager.dialogue_ended
		else:
			push_warning("garden_signages.dialogue not found!")
		return

	# 4) No valid setup
	push_warning("Signage has neither signage_branch nor marking_id assigned!")


# -----------------------------------
# Legacy dialogue support (unchanged)
# -----------------------------------
func _handle_legacy_dialogue() -> void:
	var gs := get_tree().get_first_node_in_group("GardenState")
	var index := 0

	if gs and gs.has("mistake_count"):
		index = clamp(gs.mistake_count, 0, dialogue_resources.size() - 1)

	if dialogue_resources.size() == 0:
		push_warning("Legacy dialogue mode active but no resources assigned.")
		return

	var dlg := dialogue_resources[index]
	DialogueManager.show_dialogue_balloon(dlg)
	await DialogueManager.dialogue_ended
