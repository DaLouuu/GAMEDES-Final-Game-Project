extends Node2D

@onready var area = $StaticBody2D/Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player_scene = load("res://dev/character/player/player_cat.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	player.position = Vector2(300, 200)  # change as needed
	area.connect("area_entered", Callable(self, "_on_body_entered"))
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Player can interact with this object!")
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
