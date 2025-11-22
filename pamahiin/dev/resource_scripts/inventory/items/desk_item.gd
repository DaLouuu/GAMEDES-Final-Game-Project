extends Node2D

signal item_clicked(item: InvItem)
signal item_hovered(item: InvItem)
signal item_unhovered(item: InvItem)

var is_player_in_area = false
var is_mouse_hovering = false
var player = null
@export var item: InvItem

# References to child nodes
@onready var area_2d = $Area2D
@onready var sprite_2d = $Sprite2D

# Hover icon
var hover_icon: Sprite2D
var original_cursor: Input.CursorShape = Input.CURSOR_ARROW

func _ready():
	# Set up Area2D for mouse detection
	if area_2d:
		area_2d.input_pickable = true
		area_2d.mouse_entered.connect(_on_mouse_entered)
		area_2d.mouse_exited.connect(_on_mouse_exited)
		area_2d.input_event.connect(_on_input_event)
	
	# Create hover icon
	create_hover_icon()

func create_hover_icon():
	# Create a sprite for the hover icon
	hover_icon = Sprite2D.new()
	hover_icon.name = "HoverIcon"
	hover_icon.texture = load("res://art/icons/inspect.png")
	hover_icon.visible = false
	hover_icon.z_index = 10  # Make sure it's above everything
	
	# Position it above the item
	if sprite_2d and sprite_2d.texture:
		var sprite_height = sprite_2d.texture.get_height() * sprite_2d.scale.y
		hover_icon.position = Vector2(0, -sprite_height / 2 - 20)  # 20 pixels above
	else:
		hover_icon.position = Vector2(0, -30)
	
	# Scale down the icon if needed
	hover_icon.scale = Vector2(0.5, 0.5)
	
	add_child(hover_icon)

func _process(_delta):
	# Original keyboard interaction
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

func on_item_clicked():
	print("🖱️ Item clicked: ", item.name if item else "Unknown")
	item_clicked.emit(item)
	
	# If player is in range, collect the item
	if is_player_in_area and player:
		collect_item()

# Visual feedback
func show_hover_feedback():
	# Show hover icon
	if hover_icon:
		hover_icon.visible = true
	
	# Change cursor
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	
	# Optional: Add a subtle scale effect to the sprite
	if sprite_2d:
		var tween = create_tween()
		tween.tween_property(sprite_2d, "scale", sprite_2d.scale * 1.1, 0.2)

func hide_hover_feedback():
	# Hide hover icon
	if hover_icon:
		hover_icon.visible = false
	
	# Reset cursor
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
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
