extends CharacterBody2D

@export var walk_speed := 100.0
@export var run_speed := 200.0
var current_speed := 0.0

@onready var interaction_area = $InteractionArea
var ui: Node

var is_on_stone_path := true
var is_in_sacred_zone := false
var current_interactable: Node = null

func _ready():
	add_to_group("player")
	
	# Get UI reference - wait a moment for scene to be ready
	await get_tree().process_frame
	ui = get_tree().current_scene.get_node("UI")
	
	# Create placeholder - use a ColorRect for now
	var color_rect = ColorRect.new()
	color_rect.size = Vector2(32, 32)
	color_rect.color = Color.WHITE
	color_rect.name = "PlayerVisual"
	add_child(color_rect)
	
	# Add collision for the player body
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(32, 32)
	collision.shape = shape
	add_child(collision)

func _physics_process(delta):
	handle_movement()
	handle_input()
	if ui:
		update_ui_prompts()

func handle_movement():
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_pressed("run"):
		current_speed = run_speed
		if input_dir.length() > 0:
			NoiseMeter.add_noise(40 * get_process_delta_time())
	else:
		current_speed = walk_speed
	
	velocity = input_dir * current_speed
	move_and_slide()

func handle_input():
	if Input.is_action_just_pressed("interact") and current_interactable:
		current_interactable.interact()
	
	if Input.is_action_just_pressed("greet"):
		if is_in_sacred_zone:
			EventBus.player_greeted.emit()
			if ui:
				ui.show_message("Tabi-tabi po", Color.LIGHT_BLUE)
			SanityMeter.increase_sanity(5)
		elif ui:
			ui.show_message("No need to greet here", Color.GRAY)
	
	if Input.is_action_just_pressed("look_back"):
		EventBus.player_looked_back.emit()
		SanityMeter.decrease_sanity(10)
		if ui:
			ui.show_message("You looked back! -10% sanity", Color.ORANGE)
	
	# Dev menu shortcuts
	if Input.is_action_just_pressed("cheat_menu"):
		get_node("/root/CheatMenu").toggle_menu()

func update_ui_prompts():
	if is_in_sacred_zone:
		ui.show_interact_prompt("Press G to say 'Tabi-tabi po'")
	elif current_interactable:
		ui.show_interact_prompt("Press E to interact")
	else:
		ui.hide_interact_prompt()

# These methods are called by the InteractionArea
func _on_interaction_area_entered(area):
	if area.is_in_group("interactable"):
		current_interactable = area
		print("Interactable entered: ", area.name)

func _on_interaction_area_exited(area):
	if area == current_interactable:
		current_interactable = null
		print("Interactable exited")

func _on_sacred_zone_entered(zone_id):
	is_in_sacred_zone = true
	print("Entered sacred zone: ", zone_id)

func _on_sacred_zone_exited(zone_id):
	is_in_sacred_zone = false
	print("Exited sacred zone: ", zone_id)
