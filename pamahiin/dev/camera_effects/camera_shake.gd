class_name CameraShake
extends CameraEffect

@export var strength = 10
@export var decay = 5.0
var current_strength := 0.0
var original_offset := Vector2.ZERO

func start(original_offset_value: Vector2):
	original_offset = original_offset_value
	current_strength = strength
	
func apply(camera: Camera2D, delta:float):
	if current_strength  <= 0:
		camera.offset = original_offset
		is_finished = true
		return
	camera.offset = original_offset + (Vector2(randf() - 0.5, randf()-0.5) * current_strength * 8.0)
	current_strength = lerp(current_strength, 0.0, delta * decay)
	
