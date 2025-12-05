extends Node

signal garden_state_ready(state)

@export var cicada_timer: Timer
@export var cicada_player: AudioStreamPlayer
@export var stick_scene: PackedScene 

# FOG + FLASH VARIABLES
@export var fog: CanvasItem
@export var fog_parallax_layer: ParallaxLayer = null
@export var fog_node_path: NodePath = ""
@export var fog_increase_rate := 0.02
@export var max_fog_density := 0.85
@export var flash_rect: ColorRect
@export var flash_duration := 0.25

# FOG PULSE SETTINGS
@export var base_fog_density: float = 0.25
@export var fog_per_mistake: float = 0.10
@export var pulse_speed: float = 2.0
@export var pulse_amount: float = 0.15

# SHAKE VARIABLES
var _is_shaking_continuously: bool = false
var _continuous_shake_intensity: float = 0.0

var _original_lighting_color: Color = Color.WHITE
var _original_lighting_alpha: float = 0.0
var zone_a_locked: bool = false
var _garden_state_ready: bool = false

# Internal tracker for lerp
var fog_density: float = 0.25 

func _ready():
	add_to_group("ZoneAController")
	if flash_rect:
		_original_lighting_color = flash_rect.color
		_original_lighting_alpha = flash_rect.modulate.a
		flash_rect.visible = true

	_setup_controller_fallback()
	_connect_treedoors()
	_connect_cicada_timer()
	set_process(true)

func _process(delta):
	_update_fog(delta)
	_handle_continuous_shake(delta)

# ---------------------------------------------------------
# NEW: CLEANUP FUNCTION (Fixes your error)
# ---------------------------------------------------------
func cleanup_for_ending():
	# 1. Stop Audio
	stop_cicadas()
	
	# 2. Stop Shaking
	stop_continuous_shake()
	
	# 3. Kill Visuals (Fog & Flash)
	fog_density = 0.0
	
	if fog_parallax_layer:
		var fog_sprite = fog_parallax_layer.get_node_or_null(fog_node_path)
		if fog_sprite and fog_sprite.material:
			fog_sprite.material.set("shader_parameter/density", 0.0)
	elif fog and fog.material:
		fog.material.set("shader_parameter/density", 0.0)
		
	if flash_rect:
		flash_rect.visible = false
		flash_rect.color = Color(0,0,0,0)

# ---------------------------------------------------------
# SHAKE LOGIC
# ---------------------------------------------------------
func start_continuous_shake(intensity: float = 3.0):
	_is_shaking_continuously = true
	_continuous_shake_intensity = intensity

func stop_continuous_shake():
	_is_shaking_continuously = false
	var camera = get_viewport().get_camera_2d()
	if camera:
		camera.offset = Vector2.ZERO

func _handle_continuous_shake(_delta: float):
	if not _is_shaking_continuously: return
	
	var camera = get_viewport().get_camera_2d()
	if camera:
		var offset_x = randf_range(-_continuous_shake_intensity, _continuous_shake_intensity)
		var offset_y = randf_range(-_continuous_shake_intensity, _continuous_shake_intensity)
		camera.offset = Vector2(offset_x, offset_y)

func shake_camera(intensity: float = 2.0, duration: float = 1.0):
	if _is_shaking_continuously: return
	
	var camera = get_viewport().get_camera_2d()
	if not camera: return
	var tween = create_tween()
	var start_offset = camera.offset
	var steps = 10
	var step_duration = duration / float(steps)
	for i in range(steps):
		var rand_offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(camera, "offset", start_offset + rand_offset, step_duration)
	tween.tween_property(camera, "offset", start_offset, 0.1)

# ---------------------------------------------------------
# SETUP & FALLBACK
# ---------------------------------------------------------
func _setup_controller_fallback():
	if Global.game_controller != null:
		call_deferred("_retry_attach_garden_state")
		return
	var temp_gc = GameController.new()
	temp_gc.name = "TempGameController"
	if not "garden_state" in temp_gc:
		temp_gc.set_meta("garden_state", null) 
	else:
		temp_gc.garden_state = null
	Global.game_controller = temp_gc
	call_deferred("_retry_attach_garden_state")

func _retry_attach_garden_state():
	if _garden_state_ready: return
	var gc = Global.game_controller
	if gc == null:
		call_deferred("_retry_attach_garden_state")
		return
	var candidates = get_tree().get_nodes_in_group("GardenState")
	var gs = null
	if candidates.size() == 0:
		gs = get_tree().root.find_child("GardenState", true, false)
	elif candidates.size() == 1:
		gs = candidates[0]
	else:
		for candidate in candidates:
			if candidate.get("correct_tree_markings") and not candidate.correct_tree_markings.is_empty():
				gs = candidate
				break
		if gs == null: gs = candidates[0]
	if gs:
		print("ZoneA: Attached to GardenState ID: %s" % gs.get_instance_id())
		gc.set("garden_state", gs)
		_garden_state_ready = true
		start_cicadas()
		emit_signal("garden_state_ready", gs)
	else:
		call_deferred("_retry_attach_garden_state")

# ---------------------------------------------------------
# CONNECTIONS & LOGIC
# ---------------------------------------------------------
func _connect_treedoors():
	for td in get_tree().get_nodes_in_group("treedoor"):
		if td.has_signal("correct_knock"):
			td.correct_knock.connect(_on_correct_knock)
		if td.has_signal("wrong_knock"):
			td.wrong_knock.connect(_on_wrong_knock)

func _connect_cicada_timer():
	if cicada_timer:
		if not cicada_timer.timeout.is_connected(_on_cicada_timer_timeout):
			cicada_timer.timeout.connect(_on_cicada_timer_timeout)

func _gs():
	var gc = Global.game_controller
	if gc == null: return null
	return gc.get("garden_state")

func _on_correct_knock(tree):
	var gs = _gs()
	if gs: gs.zone_a_completed = true
	print("ZoneA: Correct knock on", tree.name)
	flash_screen(Color(0.2, 1.0, 0.2))
	_spawn_stick_reward(tree.global_position)

func _spawn_stick_reward(pos: Vector2):
	if stick_scene == null:
		var gs = _gs()
		if gs: gs.total_sticks_collected += 1
		return
	var spawn_pos = pos + Vector2(0, 30) 
	var stick_instance = stick_scene.instantiate()
	stick_instance.global_position = spawn_pos
	get_tree().current_scene.call_deferred("add_child", stick_instance)

func _on_wrong_knock(tree):
	print("ZoneA: Wrong knock on", tree.name)
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if player.has_method("apply_sanity_damage"):
			player.apply_sanity_damage(5)
		elif player.has_node("sanity_component"):
			player.get_node("sanity_component").take_damage(5)
	var gs = _gs()
	if gs: gs.add_mistake()
	flash_screen(Color(1.0, 0.1, 0.1))

func start_cicadas():
	var gs = _gs()
	if gs: gs.cicadas_active = true
	if cicada_player and not cicada_player.playing: cicada_player.play()
	if cicada_timer: cicada_timer.start()

func stop_cicadas():
	if cicada_timer: cicada_timer.stop()
	var gs = _gs()
	if gs: gs.cicadas_active = false
	if cicada_player: cicada_player.stop()

func _on_cicada_timer_timeout():
	var gs = _gs()
	if gs:
		gs.cicadas_active = not gs.cicadas_active
		if gs.cicadas_active: cicada_player.play()
		else: cicada_player.stop()
	else:
		if cicada_player.playing: cicada_player.stop()
		else: cicada_player.play()

func _update_fog(delta: float) -> void:
	var gs = _gs()
	if gs == null: return
	var target_density = base_fog_density + (gs.mistake_count * fog_per_mistake)
	if gs.mistake_count >= 5:
		var time = Time.get_ticks_msec() / 1000.0
		var pulse = sin(time * pulse_speed) * pulse_amount
		target_density += pulse
	target_density = clamp(target_density, 0.0, max_fog_density)
	fog_density = lerp(fog_density, target_density, delta * 2.0)
	if fog_parallax_layer:
		var fog_sprite = fog_parallax_layer.get_node_or_null(fog_node_path)
		if fog_sprite and fog_sprite.material:
			fog_sprite.material.set("shader_parameter/density", fog_density)
		return
	if fog and fog.material:
		fog.material.set("shader_parameter/density", fog_density)

func flash_screen(target_flash_color: Color) -> void:
	if flash_rect == null: return
	flash_rect.visible = true
	flash_rect.color = target_flash_color
	flash_rect.modulate.a = 0.8
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash_rect, "color", _original_lighting_color, flash_duration)
	tween.tween_property(flash_rect, "modulate:a", _original_lighting_alpha, flash_duration)

func freeze_player(freeze: bool) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if "is_cutscene_controlled" in player:
			player.is_cutscene_controlled = freeze
		if freeze:
			if "velocity" in player: player.velocity = Vector2.ZERO
			if player.has_method("pick_new_state"): player.pick_new_state() 
			if player.has_method("update_animation_parameters"): player.update_animation_parameters(Vector2.ZERO)
