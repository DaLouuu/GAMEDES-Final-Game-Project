extends Area2D

var is_enabled := false

func _ready():
	body_entered.connect(_on_body_entered)

func enable_exit():
	is_enabled = true
	$ColorRect.color = Color(0, 1, 0, 0.5)  # Change to green when enabled

func _on_body_entered(body):
	if body.is_in_group("player") and is_enabled:
		get_tree().change_scene_to_file("res://dev/scenes/test_graveyard.tscn") # Restart for testing
