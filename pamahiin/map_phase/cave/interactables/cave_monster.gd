@tool
class_name CaveMonster
extends CharacterBody2D

enum State {
	NEUTRAL_WAITING,
	NEUTRAL_MOVING,
	ATTACKING,
	FLEEING
}

const ATTACKING_SPEED := 240
const DETARGET_DIST_THRESHOLD := 500
const NEUTRAL_GRUNT_CHANCE := 0.07
const NEUTRAL_GRUNT_FRAME_INTERVAL := 60
const NEUTRAL_MIN_DIST := 70
const NEUTRAL_MIN_WAIT := 1
const NEUTRAL_MAX_WAIT := 3
const NEUTRAL_RADIUS := 275
const NEUTRAL_SPEED := 40
const PLAYER_RAY_LENGTH := 160
const RETARGET_FRAME_COUNT := 60

const NEUTRAL_GRUNT_SOUNDS := [
	preload("uid://bc32iqv0ken2k"),
	preload("uid://bsblphcr5udly"),
	preload("uid://c3xd6jgax266v")
]
const WING_FLAP_SOUNDS := [
	preload("res://art/Audio Assets/Cave/wing_flap_1.mp3"),
	preload("res://art/Audio Assets/Cave/wing_flap_2.mp3"),
	preload("res://art/Audio Assets/Cave/wing_flap_3.mp3")
]	

const DEBUG_COLOR_FILL := Color(0.0, 1.0, 0.0, 0.1)
const DEBUG_COLOR_LINE := Color(0.0, 1.0, 0.0, 0.6)

signal player_attack_started
signal player_attack_ended

@onready var _animation_tree: AnimationTree = $AnimationTree
@onready var _idle_timer: Timer = $IdleTimer
@onready var _navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var _player_cast: ShapeCast2D = $Detectors/PlayerCast

@onready var _audio_stream_player: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D
@onready var _attack_scream: AudioStreamPlayer2D = $Audio/AttackScream
@onready var _fleeing_grunt: AudioStreamPlayer2D = $Audio/FleeingGrunt

var _attack_frame_counter := 0
var _initial_position := Vector2.ZERO
var _state := State.NEUTRAL_WAITING
var _grunt_frame_counter := 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	_initial_position = global_position
	_to_neutral_waiting_state()
	
	add_to_group("Enemy")

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	_process_current_state()
	_resolve_movement(delta)
	
	_grunt_frame_counter += 1
	if _grunt_frame_counter >= NEUTRAL_GRUNT_FRAME_INTERVAL:
		_grunt_frame_counter = 0
		if (_state == State.NEUTRAL_WAITING or _state == State.NEUTRAL_MOVING) and randf() < NEUTRAL_GRUNT_CHANCE:
			_play_sound(NEUTRAL_GRUNT_SOUNDS.pick_random())
	
func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, NEUTRAL_RADIUS, DEBUG_COLOR_FILL)
		draw_arc(Vector2.ZERO, NEUTRAL_RADIUS, 0, TAU, 32, DEBUG_COLOR_LINE, 1.0)

func _on_interact_area_body_entered(body: Node2D) -> void:
	if _state == State.FLEEING:
		return
	
	if body.is_in_group("Player"):
		if _state != State.ATTACKING:
			_to_attack_state()
	else:
		_to_fleeing_state()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func _on_player_collision_area_body_entered(_body: Node2D) -> void:
	player_attack_started.emit()
	
func _on_player_collision_area_body_exited(_body: Node2D) -> void:
	player_attack_ended.emit()


func play_wing_flap_sfx() -> void:	
	_play_sound(WING_FLAP_SOUNDS.pick_random())


func _resolve_movement(delta: float) -> void:
	if _state == State.NEUTRAL_WAITING:
		return
	
	var speed: float
	if _state == State.NEUTRAL_MOVING:
		speed = NEUTRAL_SPEED
	elif _state == State.ATTACKING or _state == State.FLEEING:
		speed = ATTACKING_SPEED
	
	var direction: Vector2 = _navigation_agent_2d.get_next_path_position() - global_position
	direction = direction.normalized()
	
	_animation_tree.set("parameters/Neutral/blend_position", direction)
	_animation_tree.set("parameters/Attacking/blend_position", direction)
	
	_player_cast.target_position = direction * PLAYER_RAY_LENGTH

	var intended_velocity: Vector2 = velocity.lerp(direction * speed, 5 * delta)
	
	if _navigation_agent_2d.avoidance_enabled:
		_navigation_agent_2d.set_velocity(intended_velocity)
	else:
		velocity = intended_velocity
		move_and_slide()

func _process_current_state() -> void:
	if _player_cast.is_colliding() and _state != State.FLEEING and _state != State.ATTACKING:
		var collider = _player_cast.get_collider(0) # Nearest collider
		if collider is Node2D and collider.is_in_group("Player"):
			_to_attack_state()

	if _state == State.NEUTRAL_WAITING:
		return
	
	elif _state == State.NEUTRAL_MOVING or _state == State.FLEEING:
		if _navigation_agent_2d.is_navigation_finished():
			if _state == State.NEUTRAL_MOVING:
				_to_neutral_waiting_state()
			else:
				_to_neutral_moving_state()
	
	elif _state == State.ATTACKING:
		_attack_frame_counter += 1
		var player := _get_player()
		
		if _attack_frame_counter >= RETARGET_FRAME_COUNT:
			_navigation_agent_2d.target_position = player.global_position
			
		var dist_to_player := global_position.distance_squared_to(player.global_position)
		if dist_to_player >= DETARGET_DIST_THRESHOLD ** 2:
			_to_neutral_moving_state()


func _to_neutral_waiting_state() -> void:
	_state = State.NEUTRAL_WAITING
	
	_idle_timer.start(randi_range(NEUTRAL_MIN_WAIT, NEUTRAL_MAX_WAIT))
	await _idle_timer.timeout
	
	# Safeguard against cases where this triggers after attacking or fleeing
	if _state == State.ATTACKING or _state == State.FLEEING:
		return
	
	_to_neutral_moving_state()

func _to_neutral_moving_state() -> void:
	_state = State.NEUTRAL_MOVING
	
	_navigation_agent_2d.target_position = _sample_neutral_radius_far_from_position()

func _to_attack_state() -> void:
	_state = State.ATTACKING
	_attack_scream.play()
	
	_navigation_agent_2d.target_position = _get_player().global_position
	_attack_frame_counter = 0

func _to_fleeing_state() -> void:
	_state = State.FLEEING
	_fleeing_grunt.play()
	
	_navigation_agent_2d.target_position = _sample_neutral_radius_far_from_position()


func _get_player() -> Player:
	var player := get_tree().get_first_node_in_group("Player")
	assert(player != null, "No player in scene!")
	
	return player
	
func _play_sound(stream: AudioStream) -> void:
	_audio_stream_player.stream = stream
	_audio_stream_player.play()
	
func _sample_neutral_radius() -> Vector2:
	var rand_mag := randf_range(1.0, NEUTRAL_RADIUS / 2.0)
	var rand_angle := randf_range(0, TAU)
	
	return _initial_position + Vector2(cos(rand_angle), sin(rand_angle)) * rand_mag
	
func _sample_neutral_radius_far_from_position() -> Vector2:
	var pos := _sample_neutral_radius()
	var ground_tile_map: TileMapLayer = get_tree().get_first_node_in_group("ground")
	
	while true:
		var good_dist := pos.distance_squared_to(global_position) > NEUTRAL_MIN_DIST ** 2
	#
		var tile_position := ground_tile_map.local_to_map(ground_tile_map.to_local(pos))
		var tile_data := ground_tile_map.get_cell_tile_data(tile_position)
		var not_sampleable: bool = tile_data.get_custom_data("not_sampleable")

		if good_dist and not not_sampleable:
			break

		pos = _sample_neutral_radius()
		
	return pos
