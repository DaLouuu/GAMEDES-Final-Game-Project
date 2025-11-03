class_name MoveBackForth
extends MoveType

@export var burst_interval: float = 1.8
@export var burst_duration: float = 0.25
var timer := 0.0

func get_move_vector(enemy, player, delta):
	timer += delta

	var forward = (player.global_position - enemy.global_position).normalized()

	# Retreat briefly
	if fmod(timer, burst_interval) < burst_duration:
		return -forward * move_speed * 1.4  # faster backward
	else:
		return forward * move_speed
