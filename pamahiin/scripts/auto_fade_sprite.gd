extends Sprite2D

## Auto-fade sprite when player goes behind it

# The opacity when player is behind (0.0 = invisible, 1.0 = fully visible)
@export var fade_opacity: float = 0.3

# How fast to fade in/out
@export var fade_speed: float = 5.0

# Layer to detect (set to your player's collision layer)
@export var player_layer: int = 1

# Current target opacity
var target_alpha: float = 1.0

# Detection area
var detection_area: Area2D

func _ready():
	# Create Area2D for detection
	detection_area = Area2D.new()
	detection_area.name = "PlayerDetectionArea"
	add_child(detection_area)
	
	# Create collision shape matching the sprite size
	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	
	# Get sprite size from texture
	if texture:
		var sprite_size = texture.get_size()
		rect_shape.size = sprite_size * scale
	else:
		rect_shape.size = Vector2(100, 100)  # Default size
	
	collision_shape.shape = rect_shape
	detection_area.add_child(collision_shape)
	
	# Set collision mask to detect player
	detection_area.collision_layer = 0
	detection_area.collision_mask = player_layer
	
	# Connect signals
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	detection_area.area_entered.connect(_on_area_entered)
	detection_area.area_exited.connect(_on_area_exited)

func _process(delta):
	# Smoothly lerp to target alpha
	modulate.a = lerp(modulate.a, target_alpha, fade_speed * delta)

func _on_body_entered(body):
	# Check if it's the player
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		target_alpha = fade_opacity
		print(name, " - Player detected behind sprite, fading to ", fade_opacity)

func _on_body_exited(body):
	# Player left, restore opacity
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		target_alpha = 1.0
		print(name, " - Player left, restoring opacity")

func _on_area_entered(area):
	# Also check for player's Area2D if they have one
	if area.get_parent() and (area.get_parent().is_in_group("player") or area.get_parent().name.to_lower().contains("player")):
		target_alpha = fade_opacity

func _on_area_exited(area):
	if area.get_parent() and (area.get_parent().is_in_group("player") or area.get_parent().name.to_lower().contains("player")):
		target_alpha = 1.0
