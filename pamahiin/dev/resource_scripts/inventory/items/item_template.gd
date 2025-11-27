extends Node2D

signal item_clicked(item: InvItem)
signal item_hovered(item: InvItem)
signal item_unhovered(item: InvItem)
signal item_inspected(item : InvItem) # Timing of beginning to inspect dialogue
signal item_collected(item : InvItem) # Timing upon collection of item
signal item_inspected_finish(item : InvItem) # Timing after the dialoge
signal item_emit_collected

var is_player_in_area = false
var is_mouse_hovering = false
var player = null

## Please ensure size of hover icon is 45x45 or close
@export var hover_tex : Texture2D = load("res://art/icons/inspect.png")

## Create your own resource file, extend to (class `InvItem`). attach a name, description, texture at minimum, there is also an item type
@export var item: InvItem :
	set(value):
		item = value
		_update_item()

## This makes it so that the item cannot be checked by the player from its own description
@export var isInspectable = false

## This makes the item be collectible to player's inventory
@export var isCollectible = false

## Depending on the sprite, collision might be too small and needs adjustment, open debug menu and toggle `Visible Collision Shapes` to check it grow or not.
@export var collision_scale = 1.0

@export var collision_pos_offset: Vector2 = Vector2(Vector2.ZERO)

# References to child nodes
@onready var area_2d = $Area2D
@onready var sprite_2d = $Sprite2D

@onready var collision_2d = $Area2D/CollisionShape2D

var shader_mat: ShaderMaterial
var original_cursor: Input.CursorShape = Input.CURSOR_ARROW
var original_scale: Vector2
var original_saturation: float = 1.0

var default_shader = load("res://dev/resource_scripts/inventory/items/item_template.gdshader")
var default_shader_saturation = load("res://dev/resource_scripts/inventory/items/item_template_saturation.gdshader")

func _update_item():
	if item and sprite_2d:
		sprite_2d.texture = item.texture
func _ready():
	
	collision_2d.scale *= collision_scale
	if item:
		sprite_2d.texture = item.texture
	var a = $Area2D
	a.mouse_entered.connect(_on_mouse_entered)
	a.mouse_exited.connect(_on_mouse_exited)
	a.input_event.connect(_on_input_event)
	if sprite_2d:
		original_scale = sprite_2d.scale
		var mat = ShaderMaterial.new()
		mat.shader = default_shader
		sprite_2d.material = mat
	$Area2D/CollisionShape2D.position = collision_pos_offset
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
	if is_player_in_area and Input.is_action_just_pressed("interact") and isCollectible:
		collect_item()
	elif is_player_in_area and Input.is_action_just_pressed("interact") and isInspectable and not isCollectible:
		inspect_func()
	elif is_player_in_area and Input.is_action_just_pressed("interact") and isInspectable and isCollectible:
		collect_item()
	

func collect_item():
	if not isCollectible:
		return
	item_collected.emit(item)
	item_emit_collected.emit()
	if player and item:
		player.collect(item)
		print("🎒 Collected item: ", item.name)
		# delay after collecting item
		await get_tree().create_timer(0.1).timeout
		self.queue_free()

# Mouse hover detection
func _on_mouse_entered():
	if not isInspectable and not isCollectible:
		return
	is_mouse_hovering = true
	show_hover_feedback()
	item_hovered.emit(item)
	print("🖱️ Mouse hovering over item: ", item.name if item else "Unknown")

func _on_mouse_exited():
	if not isInspectable and not isCollectible:
		return
	is_mouse_hovering = false
	hide_hover_feedback()
	item_unhovered.emit(item)

# Handle mouse clicks
func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			on_item_clicked()
			
# Enlarges and increases saturation
func enlarge_upon_near():
	if sprite_2d:
		var tween = create_tween()
		tween.tween_property(sprite_2d, "scale", sprite_2d.scale * 1.1, 0.2)
		if sprite_2d.material and sprite_2d.material is ShaderMaterial:
			print("Trying to modify shader")
			sprite_2d.material.shader = default_shader_saturation

# Resets to original scale and saturation
func reset_state():
	if sprite_2d:
		var tween = create_tween()
		tween.tween_property(sprite_2d, "scale", original_scale, 0.2)
		if sprite_2d.material and sprite_2d.material is ShaderMaterial:
			sprite_2d.material.shader = default_shader
		
func inspect_func():
	if not isInspectable:
		return
		
	item_inspected.emit(item)
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

	var runner = DialogueManager.show_example_dialogue_balloon(resource)
	DialogueManager.dialogue_ended.connect(item_emit_finish)
func item_emit_finish():
	item_inspected_finish.emit(item)
	DialogueManager.dialogue_ended.disconnect(item_emit_finish)
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
	enlarge_upon_near()
func hide_hover_feedback():

	
	# Reset cursor
	Input.set_custom_mouse_cursor(null)
	
	reset_state()
# Original Area2D body detection (for keyboard interaction)
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		$TextureRect.visible = true
		is_player_in_area = true
		enlarge_upon_near()
		player = body
		print("👤 Player entered item area: ", item.name if item else "Unknown")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		$TextureRect.visible = false
		is_player_in_area = false
		reset_state()
		player = null


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("🟩 INPUT EVENT DETECTED")
