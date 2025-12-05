extends Node2D

@onready var prompt: CanvasItem = $InteractionPrompt
@onready var trigger_area: Area2D = $Area2D

# --- EXPORT DIALOGUES ---
@export var broom_item: Resource
@export var well_dialogue_resource: Resource

# --- FIX: DECLARE THE VARIABLE HERE ---
var player_in_range: bool = false

func _ready():
	prompt.visible = false
	if trigger_area:
		trigger_area.body_entered.connect(_on_entered)
		trigger_area.body_exited.connect(_on_exited)

func _on_entered(body: Node):
	if body.is_in_group("Player"):
		player_in_range = true
		prompt.visible = true

func _on_exited(body: Node):
	if body.is_in_group("Player"):
		player_in_range = false
		prompt.visible = false

func _process(_delta: float):
	if player_in_range and Input.is_action_just_pressed("interact"):
		_try_craft_sequence()

func _try_craft_sequence():
	# Smart Search for GardenState
	var gs_candidates = get_tree().get_nodes_in_group("GardenState")
	var gs = null
	for candidate in gs_candidates:
		if candidate.get("correct_tree_markings") and not candidate.correct_tree_markings.is_empty():
			gs = candidate
			break
	
	if gs == null: return

	gs.has_rope = true

	# Check Sticks (Require 5)
	if gs.total_sticks_collected < 5:
		if well_dialogue_resource:
			DialogueManager.show_dialogue_balloon(well_dialogue_resource, "missing_sticks")
			await DialogueManager.dialogue_ended
		return

	# Craft Broom
	if well_dialogue_resource:
		DialogueManager.show_dialogue_balloon(well_dialogue_resource, "craft_broom")
		await DialogueManager.dialogue_ended

	gs.broom_crafted = true
	if broom_item and Global.inventory:
		Global.inventory.add_item(broom_item)

	# Pre-Chase Dialogue
	var final_dlg := load("res://map_phase/garden/Dialogue/final_garden.dialogue")
	if final_dlg:
		DialogueManager.show_dialogue_balloon(final_dlg, "prechase")
		await DialogueManager.dialogue_ended

	# --- TRIGGER CHASE ---
	var chase_manager = get_tree().get_first_node_in_group("GardenChaseManager")
	if chase_manager:
		chase_manager.start_chase()
	else:
		print("ERROR: GardenChaseManager node not found in scene!")

	queue_free()
