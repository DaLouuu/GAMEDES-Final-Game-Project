extends Node2D

const SLOWED_MOVE_SPEED := 20.0

var _initial_move_speed := 0.0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
		
	var player: Player = body
	_initial_move_speed = player.move_speed
	player.move_speed = SLOWED_MOVE_SPEED

func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
		
	var player: Player = body
	player.move_speed = _initial_move_speed
