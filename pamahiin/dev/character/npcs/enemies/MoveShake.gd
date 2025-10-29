class_name MoveShake
extends MoveType

@export var shake_amount: float = 20.0

func get_move_vector(enemy, player, delta):
	var forward = (player.global_position - enemy.global_position).normalized()
	var shake = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized() * shake_amount * delta

	var dist = enemy.global_position.distance_to(player.global_position)
	var aggression = clamp(dist / 200.0, 0.2, 1.0)
	shake *= aggression




	var final = (forward + shake).normalized()
	return final * move_speed
	
