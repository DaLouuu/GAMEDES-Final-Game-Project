# ZigZagMove.gd
class_name MoveZigZag
extends MoveType

@export var zigzag_frequency: float = 3.0
@export var zigzag_amplitude: float = 10.0

func get_move_vector(enemy, player, delta):
	var forward = (player.global_position - enemy.global_position).normalized()
	var perpendicular = forward.orthogonal()

	var zigzag_offset = sin(Time.get_ticks_msec() / 1000.0 * zigzag_frequency) * zigzag_amplitude
	var final = (forward + perpendicular * zigzag_offset).normalized()

	return final * move_speed
