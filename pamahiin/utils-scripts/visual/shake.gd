extends Node2D

@export var max_distance: float = 10.0
@export var speed: float = 50.0 
@export var duration: float = 0.5 # (0.0 for infinite).

var is_shaking: bool = false
var elapsed_time: float = 0.0
var original_position: Vector2

func _ready():
	original_position = position

func _process(delta: float):
	if is_shaking:
		elapsed_time += delta

		var offset_x = sin(elapsed_time * speed * 1.5) * max_distance * 0.7
		var offset_y = cos(elapsed_time * speed * 1.3) * max_distance * 0.7

		position = original_position + Vector2(offset_x, offset_y)

		if duration > 0.0 and elapsed_time >= duration:
			stop_shake()

func start_shake(new_duration: float = -1.0):
	if is_shaking:
		return

	if new_duration >= 0.0:
		duration = new_duration

	original_position = position

	is_shaking = true
	elapsed_time = 0.0

func stop_shake():
	is_shaking = false
	position = original_position
