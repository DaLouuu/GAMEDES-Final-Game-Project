class_name MoveSimple
extends MoveType



func get_move_vector(enemy, player, delta):
	return (player.global_position - enemy.global_position).normalized() * move_speed
