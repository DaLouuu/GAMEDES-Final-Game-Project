class_name CameraBlur
extends CameraEffect

@export var blur_time: float = 0.4
@export var blur_strength: float = 4.0

var t := 0.0
var original_blur := 0.0
var env

func start(env_value):
	env = env_value
	original_blur = env.environment.dof_blur_far_amount
	t = 0.0

func apply(camera: Camera2D, delta: float):
	t += delta
	
	var amt = lerp(blur_strength, 0.0, t / blur_time)
	env.environment.dof_blur_far_amount = amt
	
	if t >= blur_time:
		env.environment.dof_blur_far_amount = original_blur
		is_finished = true
