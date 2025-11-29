class_name AttackImpact
extends Node

const FRAMES_PER_SHAKE := 2
const SHAKE_LERP_SMOOTH := 7
const SHAKE_RADIUS := 55

@onready var _jumpscare: Sprite2D = $Jumpscare
@onready var _screech_player: AudioStreamPlayer = $ScreechPlayer

var _attack_ongoing := false
var _attack_frame := 0
var _jumpscare_instance: Sprite2D
var _shake_vector := Vector2.ZERO

func _ready() -> void:
	_jumpscare_instance = _jumpscare.duplicate()
	_jumpscare_instance.visible = true
	
func _process(delta: float) -> void:
	if not _attack_ongoing:
		_attack_frame = 0
		return 
		
	if _attack_frame % FRAMES_PER_SHAKE == 0:
		_shake_vector = _rand_point_in_circle(SHAKE_RADIUS)
		
		if randf() < 0.5:
			_jumpscare_instance.visible = true
		else:
			_jumpscare_instance.visible = false
	
	_attack_frame += 1
	
	var player := _get_player()
	player.camera.offset = player.camera.offset.lerp(_shake_vector, SHAKE_LERP_SMOOTH * delta)
	
	
func start() -> void:
	if not is_inside_tree():
		return
	
	_attack_ongoing = true
	_screech_player.play()
	_get_player().add_child(_jumpscare_instance)
	
func stop() -> void:
	if not is_inside_tree():
		return
	
	_attack_ongoing = false
	_get_player().remove_child(_jumpscare_instance)	
	
func _get_player() -> Player:
	var player := get_tree().get_first_node_in_group("Player")
	assert(player != null, "No player in scene!")
	return player
	
func _rand_point_in_circle(radius: float) -> Vector2:
	var angle := randf_range(0, TAU)
	return Vector2(cos(angle), sin(angle)) * radius
