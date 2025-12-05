extends Node2D

const CAMERA_ZOOM := 3.0
const PLAYER_MOVE_SPEED := 65
const PLAYER_SCALE := 0.5
const PLAYER_SPRINT_MULTIPLAYER := 1.75
const SANITY_DAMAGE := 13

const _CAVE_ENDING_DIALOGUE = preload("uid://cploqh0i3n2c5")

@onready var _attack_impact: AttackImpact = $AttackImpact
@onready var _attack_timer: Timer = $AttackTimer
@onready var _end_entrance_shadow: Sprite2D = $Map/Regions/EndEntrance/Shadow
@onready var _rest_point: DirectionMarker = $Map/Center/RestPoint
@onready var customMarker := $"Marker2D-Custom"
var _attack_ongoing := false
var _attacker_count := 0
var _has_entered_main_room := false
func getCustomMarker(_local: EnumsRef.LOCAL_FROM_TYPE = EnumsRef.LOCAL_FROM_TYPE.CAVE):
	return customMarker

func player_reset():
	Global.game_controller.change_2d_scene("uid://dnvq5fs7tu167")
func _ready() -> void:
	_get_player().player_resetted.connect(player_reset)
	
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Master"), 0, true)
	for enemy: CaveMonster in _get_enemies():
		enemy.player_attack_started.connect(_on_player_attack_started)
		enemy.player_attack_ended.connect(_on_player_attack_ended)

func _enter_tree() -> void:
	_init_player()
	
func _exit_tree() -> void:
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Master"), 0, false)
	
func _on_attack_timer_timeout() -> void:
	_get_player().ReceiveSanityDamage(_attacker_count * SANITY_DAMAGE, EnumsRef.HitEffectType.HitEffectCustom)
func makePlayerObtain():
	_get_player().collect(load("uid://bpep1reenml12"))
	GameState.CAVE_has_salt = true
func _on_end_entrance_body_entered(_body: Node2D) -> void:
	if not _has_entered_main_room:
		_has_entered_main_room = true
		
		var player := _get_player()

		await player.move_towards(_rest_point)
		player.is_cutscene_controlled = true
		
		DialogueManager.show_dialogue_balloon(_CAVE_ENDING_DIALOGUE)
		await DialogueManager.dialogue_ended
		player.is_cutscene_controlled = false
		
		_end_entrance_shadow.visible = true
	else:
		Global.game_controller.change_2d_scene_custom("uid://cyc8laq2oakj0", EnumsRef.LOCAL_FROM_TYPE.CAVE)
		

func _on_main_entrance_body_entered(body: Node2D) -> void:
	if not is_inside_tree():
		return
	
	if not body.is_in_group("Player"):
		return

	Global.game_controller.change_2d_scene_custom("uid://cyc8laq2oakj0", EnumsRef.LOCAL_FROM_TYPE.CAVE)

func _on_player_attack_started() -> void:
	_attacker_count += 1
	
	if not _attack_ongoing:
		_attack_ongoing = true
		_attack_impact.start()
		
		_get_player().ReceiveSanityDamage(_attacker_count * SANITY_DAMAGE, EnumsRef.HitEffectType.HitEffectCustom)
		_attack_timer.start()
	
func _on_player_attack_ended() -> void:
	_attacker_count -= 1

	if _attack_ongoing:
		_attack_ongoing = false
		_attack_impact.stop()
		
		_attack_timer.stop()
	
	
func _get_enemies() -> Array[Node]:
	var enemies := get_tree().get_nodes_in_group("Enemy")
	return enemies

func _get_player() -> Player:
	if not is_inside_tree():
		return
	
	var player := get_tree().get_first_node_in_group("Player")
	assert(player != null, "No player in scene!")
	return player

func _init_player() -> void:
	var player := _get_player()

	player.scale = Vector2(PLAYER_SCALE, PLAYER_SCALE)
	player.move_speed = PLAYER_MOVE_SPEED
	player.sprint_multiplier = PLAYER_SPRINT_MULTIPLAYER
	player.camera.zoom = Vector2(CAMERA_ZOOM, CAMERA_ZOOM)
	
	# Debug only:
	player.turnOnLight()
	
	player.set_collision_mask_value(1, false)
	player.set_collision_mask_value(2, true)
