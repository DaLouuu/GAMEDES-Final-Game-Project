extends Node2D

@onready var area = $StaticBody2D/Area2D
@onready var scene_cam = $SceneCamera

var player: Node = null
var _camera_active := false

func _ready() -> void:
	# Make sure _process runs
	set_process(true)
	
	player = get_node_or_null("PlayerCat")
	# Connect the area signal if not connected in editor
	if player:
		var player_cam = player.get_node("Camera2D")
		if player_cam:
			player_cam.zoom = Vector2(1.75, 1.75)
			_camera_active = true

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	player = body  # reference the existing player

	# Disable player's camera
	var player_cam = player.get_node("Camera2D")
	if player_cam:
		player_cam.zoom = Vector2(1.5,1.5)

	_camera_active = true

	print("Motel camera active!")
