extends Camera2D

var shake_strength = 0.0
var shake_decay = 5.0
var original_offset = Vector2.ZERO

func _ready():
	original_offset = offset

func _process(delta):
	if shake_strength > 0:
		offset = original_offset + Vector2(randf() - 0.5, randf() - 0.5) * shake_strength * 10.0
		shake_strength = lerp(shake_strength, 0.0, delta * shake_decay)

	else:
		offset = original_offset

func start_shake(strength: float = 0.2):
	shake_strength = strength
