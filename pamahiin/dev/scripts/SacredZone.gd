extends Area2D

@export var zone_id := "gate" 

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Create visual 
	var visual = ColorRect.new() 
	visual.size = Vector2(100, 100) 
	visual.color = Color(1, 0, 0, 0.3) 
	visual.name = "ZoneVisual" 
	add_child(visual)
	
	# Add collision 
	var collision = CollisionShape2D.new() 
	var shape = RectangleShape2D.new() 
	shape.size = Vector2(100, 100) 
	collision.shape = shape
	add_child(collision)

func _on_body_entered(body): 
	if body.is_in_group("player"): 
		EventBus.sacred_zone_entered.emit(zone_id) 

func _on_body_exited(body): 
	if body.is_in_group("player"): 
		EventBus.sacred_zone_exited.emit(zone_id)
