extends Node2D

@export var signage_branch: String = ""        
@export var marking_id: String = ""            

@onready var prompt := $InteractionPrompt
@onready var interact_area := $Area2D

var player_in_range: bool = false

# List of signages that should NEVER change based on mistakes
const STATIC_SIGNAGES = ["gate_signage", "well_signage", "boulder_signage", "found_signage_1", "found_signage_2", "found_signage_3"]

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
	var zone_a = get_tree().get_first_node_in_group("ZoneAController")
	if zone_a: zone_a.freeze_player(true)
	
	var mistakes = 0
	var gs_candidates = get_tree().get_nodes_in_group("GardenState")
	for candidate in gs_candidates:
		if candidate.get("mistake_count") != null:
			mistakes = candidate.mistake_count
			break
	
	# 1. Handle Named Signages (Gate, Well, etc.)
	if signage_branch != "":
		var dlg_res := load("res://map_phase/garden/Dialogue/garden_signages.dialogue")
		if dlg_res:
			var final_branch = signage_branch
			
			# ONLY apply mistake swapping if it is NOT a static sign
			if signage_branch not in STATIC_SIGNAGES:
				final_branch = "%s_%d" % [signage_branch, mistakes]
				if mistakes > 3: final_branch = "%s_%d" % [signage_branch, 3]
			
			# Play the dialogue
			DialogueManager.show_dialogue_balloon(dlg_res, final_branch)
			await DialogueManager.dialogue_ended

			# Trigger Intro Sequence (Gate Only)
			if signage_branch == "gate_signage":
				var chase := get_tree().get_first_node_in_group("GardenChaseManager")
				if chase:
					chase.trigger_intro_gate_sequence()
	
	# 2. Handle Tree Notes (These SHOULD swap if you want them to, or use marking_id logic)
	elif marking_id != "":
		var tree_branch := "%s_tree" % marking_id
		var dlg_res2 := load("res://map_phase/garden/Dialogue/garden_signages.dialogue")
		if dlg_res2:
			DialogueManager.show_dialogue_balloon(dlg_res2, tree_branch)
			await DialogueManager.dialogue_ended

	if zone_a: zone_a.freeze_player(false)
