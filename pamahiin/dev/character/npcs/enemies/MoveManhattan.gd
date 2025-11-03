class_name MoveManhattan
extends MoveType

func get_move_vector(enemy, player, delta):
	var diff = player.global_position - enemy.global_position

	# Choose the dominant axis
	if abs(diff.x) > abs(diff.y):
		# Move horizontally
		return Vector2(sign(diff.x), 0) * move_speed
	else:
		# Move vertically
		return Vector2(0, sign(diff.y)) * move_speed
