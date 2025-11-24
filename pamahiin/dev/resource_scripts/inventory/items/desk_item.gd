extends Node2D

signal item_clicked(item: InvItem)
signal item_hovered(item: InvItem)
signal item_unhovered(item: InvItem)

var is_player_in_area = false
var is_mouse_hovering = false
var player = null
@export var hover_tex : Texture2D = load("res://art/icons/inspect.png")

@export var item: InvItem

# References to child nodes
@onready var area_2d = $Area2D
@onready var sprite_2d = $Sprite2D


var original_cursor: Input.CursorShape = Input.CURSOR_ARROW

func _enter_tree():
	$Area2D.input_pickable = true
	$Area2D.z_index = 100

func _ready():
	await get_tree().process_frame

	var a = $Area2D
	a.mouse_entered.connect(_on_mouse_entered)
	a.mouse_exited.connect(_on_mouse_exited)
	a.input_event.connect(_on_input_event)


func create_hover_icon():
	pass
	## Create a sprite for the hover icon
#
#
	## Position it above the item
	#if sprite_2d and sprite_2d.texture:
		#var sprite_height = sprite_2d.texture.get_height() * sprite_2d.scale.y
		#hover_icon.position = Vector2(0, -sprite_height / 2 - 20)  # 20 pixels above
	#else:
		#hover_icon.position = Vector2(0, -30)
	#
	## Scale down the icon if needed
	#hover_icon.scale = Vector2(0.5, 0.5)
	#
	#add_child(hover_icon)

func _process(_delta):
	if is_player_in_area and Input.is_action_just_pressed("interact"):
		collect_item()

func collect_item():
	if player and item:
		player.collect(item)
		print("🎒 Collected item: ", item.name)
		
		# delay after collecting item
		await get_tree().create_timer(0.1).timeout
		self.queue_free()

# Mouse hover detection
func _on_mouse_entered():
	is_mouse_hovering = true
	show_hover_feedback()
	item_hovered.emit(item)
	print("🖱️ Mouse hovering over item: ", item.name if item else "Unknown")

func _on_mouse_exited():
	is_mouse_hovering = false
	hide_hover_feedback()
	item_unhovered.emit(item)

# Handle mouse clicks
func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_item_clicked()
func inspect_func():
	var resource = DialogueResource.new()
	var count := 0
	var line_ids := []  # store all line ids to reference next_id

	for desc in item.description:
		var line_id = "line_" + str(count)
		line_ids.append(line_id)
		count += 1
			
	# Create lines with proper next_id
	for i in range(line_ids.size()):
		var line_data = {
			"text": item.description[i],
			"type": DMConstants.TYPE_DIALOGUE,
			"next_id": line_ids[i + 1] if i < line_ids.size() - 1 else DMConstants.ID_END
		}
		resource.lines[line_ids[i]] = line_data

	# Set the first line as starting point
	resource.first_title = line_ids[0]

	DialogueManager.show_example_dialogue_balloon(resource)
func on_item_clicked():
	print("🖱️ Item clicked: ", item.name if item else "Unknown")
	item_clicked.emit(item)
	
	inspect_func()
	# If player is in range, collect the item
	if is_player_in_area and player:
		collect_item()

# Visual feedback
func show_hover_feedback():

	# Change cursor
	Input.set_custom_mouse_cursor(hover_tex, Input.CURSOR_ARROW, Vector2(20,20))

	# Optional: Add a subtle scale effect to the sprite
	if sprite_2d:
		var tween = create_tween()
		tween.tween_property(sprite_2d, "scale", sprite_2d.scale * 1.1, 0.2)

func hide_hover_feedback():

	
	# Reset cursor
	Input.set_custom_mouse_cursor(null)
	
	# Reset sprite scale
	if sprite_2d:
		var tween = create_tween()
		tween.tween_property(sprite_2d, "scale", sprite_2d.scale / 1.1, 0.2)

# Original Area2D body detection (for keyboard interaction)
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		is_player_in_area = true
		player = body
		print("👤 Player entered item area: ", item.name if item else "Unknown")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		is_player_in_area = false
		player = null


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("🟩 INPUT EVENT DETECTED")
