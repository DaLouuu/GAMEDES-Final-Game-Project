extends Area2D

@export var is_correct_candle := true 
@onready var sanity_manager = get_node("/root/SanityMeter") 

func _ready():
	add_to_group("interactable")
	
	# Set collision layer/mask to interact with player's InteractionArea
	collision_layer = 0  # Reset
	collision_mask = 2   # Match the layer of InteractionArea
	
	# Create placeholder visual
	var visual = ColorRect.new()
	visual.size = Vector2(20, 20)
	if is_correct_candle:
		visual.color = Color.WHITE
	else:
		visual.color = Color.GRAY
	visual.name = "CandleVisual"
	add_child(visual)
	
	# Add collision
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(20, 20)
	collision.shape = shape
	add_child(collision)

func interact():
	print("Candle interacted: ", name, " - Correct: ", is_correct_candle)
	var collected = Inventory.collect_candle(is_correct_candle)
	if collected:
		if not is_correct_candle:
			EventBus.entity_attached.emit()
			SanityMeter.decrease_sanity(10)  # Initial penalty
			queue_free()  # Remove candle from scene

func _on_body_entered(body): 
	if body.is_in_group("player"): 
		# Show UI prompt: "Press E to inspect" 
		pass
