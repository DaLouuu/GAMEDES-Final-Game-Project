@tool
class_name Crystal
extends StaticBody2D

const DURATION := 0.1

@onready var _glow_sound: AudioStreamPlayer2D = $GlowSound
@onready var _point_light: PointLight2D = $PointLight2D

var _tween: Tween

@export var brightness := 1.0:
	set(v):
		brightness = v
		
		if is_node_ready() and glowing:
			_update_light_state()

@export var texture_scale := 0.25:
	set(v):
		texture_scale = v
		if is_node_ready() and glowing:
			_update_light_state()

@export var glowing := false:
	set(v):
		var prev_val := glowing
		glowing = v
		
		if not is_node_ready():
			await ready
			_update_light_state()
		else:
			_update_light_state(not prev_val)

func _update_light_state(play_sound := false) -> void:
	if _tween:
		_tween.kill()
		
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_QUAD)
	
	# Set parallel so size and brightness animate simultaneously
	_tween.set_parallel()
	
	var target_energy = brightness if glowing else 0.0
	var target_scale = texture_scale if glowing else 0.0
	
	_tween.tween_property(_point_light, "energy", target_energy, DURATION)
	_tween.tween_property(_point_light, "texture_scale", target_scale, DURATION)
	
	# Only play sound if we are turning on
	if glowing and play_sound:
		_glow_sound.play()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if glowing or not body.is_in_group("Player"):
		return
		
	glowing = true
