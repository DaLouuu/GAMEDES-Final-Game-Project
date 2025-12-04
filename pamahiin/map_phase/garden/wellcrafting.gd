extends Node2D

@onready var prompt: CanvasItem = $InteractionPrompt
@onready var trigger_area: Area2D = $Area2D   # <-- connects to the child, not self

var player_in_range: bool = false

@export var broom_item: Resource


func _ready():
	prompt.visible = false

	# Connect to the AREA2D, not to the Node2D itself
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
		_interact()


func _interact() -> void:
	var gs = get_tree().get_first_node_in_group("GardenState")
	if gs == null:
		push_warning("WellInteraction: GardenState not found.")
		return

	# ---------------------------------------------------------
	# 1) PLAY WELL SIGNAGE DIALOGUE
	# ---------------------------------------------------------
	var dlg_res := load("res://dialogues/garden/garden_signages.dialogue")
	if dlg_res:
		DialogueManager.show_dialogue_resource(dlg_res, "well_signage")
		await DialogueManager.dialogue_ended

	# Give rope
	gs.has_rope = true


	# ---------------------------------------------------------
	# 3) CHECK IF PLAYER HAS ENOUGH STICKS
	# ---------------------------------------------------------
	if gs.total_sticks_collected < 1:
		DialogueManager.show_dialogue_balloon_from_text(
			"[#thinking] I found rope… but I still need sticks."
		)
		await DialogueManager.dialogue_ended
		return


	# ---------------------------------------------------------
	# 4) AUTO-CRAFT WALIS TINGTING
	# ---------------------------------------------------------
	DialogueManager.show_dialogue_balloon_from_text(
		"[#thinking] Rope… and the sticks I gathered.\nI can tie them together.\nA walis tingting, just like she made."
	)
	await DialogueManager.dialogue_ended

	if broom_item and Global.inventory:
		Global.inventory.add_item(broom_item)


	# ---------------------------------------------------------
	# 5) PRE-CHASE DIALOGUE
	# ---------------------------------------------------------
	var final_dlg := load("res://dialogues/garden/final_garden.dialogue")
	if final_dlg:
		DialogueManager.show_dialogue_resource(final_dlg, "prechase")
		await DialogueManager.dialogue_ended


	# ---------------------------------------------------------
	# 6) START THE CHASE
	# ---------------------------------------------------------
	var chase := get_tree().get_first_node_in_group("GardenChaseManager")
	if chase:
		chase.start_chase()
	else:
		push_warning("WellInteraction: GardenChaseManager not found.")


	# ---------------------------------------------------------
	# 7) REMOVE WELL INTERACTION (cannot craft twice)
	# ---------------------------------------------------------
	queue_free()
