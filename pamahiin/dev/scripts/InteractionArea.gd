extends Area2D

func _ready():
	# Create collision shape if it doesn't exist
	if get_child_count() == 0:
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(50, 50)  # Larger than player for better interaction
		collision.shape = shape
		add_child(collision)
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Forward the signal to the player
	if get_parent().has_method("_on_interaction_area_entered"):
		get_parent()._on_interaction_area_entered(body)

func _on_body_exited(body):
	# Forward the signal to the player  
	if get_parent().has_method("_on_interaction_area_exited"):
		get_parent()._on_interaction_area_exited(body)
