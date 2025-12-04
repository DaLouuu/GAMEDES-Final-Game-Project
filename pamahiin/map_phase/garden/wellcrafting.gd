extends Node2D

@onready var prompt: CanvasItem = $InteractionPrompt
@onready var trigger_area: Area2D = $Area2D

var player_in_range: bool = false

@export var broom_item: Resource

func _ready():
	prompt.visible = false
	trigger_area.body_entered.connect(_on_entered)
	trigger_area.body_exited.connect(_on_exited)


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
		_try_craft_sequence()


func _try_craft_sequence() -> void:
	var gs = get_tree().get_first_node_in_group("GardenState")
	if gs == null:
		push_warning("WellInteraction: GardenState not found.")
		return

	# 1. Acquire Rope logic
	gs.has_rope = true

	# 2. Check if we have the Sticks from the trees
	if gs.total_sticks_collected < 1:
		_play_missing_sticks_dialogue()
		return

	# 3. If we have sticks + rope, craft the broom
	_perform_crafting(gs)


func _play_missing_sticks_dialogue() -> void:
	DialogueManager.show_dialogue_balloon_from_text(
		"[#thinking] I found rope… but I still need sticks."
	)
	await DialogueManager.dialogue_ended


func _perform_crafting(gs: Node) -> void:
	# A. Crafting Dialogue
	DialogueManager.show_dialogue_balloon_from_text(
		"[#thinking] Rope… and the sticks I gathered.\nI can tie them together.\nA walis tingting, just like she made."
	)
	await DialogueManager.dialogue_ended

	# B. Add Item
	gs.broom_crafted = true
	if broom_item and Global.inventory:
		Global.inventory.add_item(broom_item)

	# C. Pre-Chase Dialogue (Cutscene)
	var final_dlg := load("res://dialogues/garden/final_garden.dialogue")
	if final_dlg:
		DialogueManager.show_dialogue_resource(final_dlg, "prechase")
		await DialogueManager.dialogue_ended

	# D. Trigger Chase
	var chase := get_tree().get_first_node_in_group("GardenChaseManager")
	if chase:
		chase.start_chase()
	else:
		push_warning("WellInteraction: GardenChaseManager not found.")

	# E. Remove this interaction so it can't be triggered again
	queue_free()
