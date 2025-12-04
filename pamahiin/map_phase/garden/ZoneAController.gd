extends Node

signal garden_state_ready(state)

@export var cicada_timer: Timer
@export var cicada_player: AudioStreamPlayer
@export var trunk_textures: Array[Texture2D] = []

# FOG + FLASH VARIABLES
@export var fog: CanvasItem
@export var fog_parallax_layer: ParallaxLayer = null
@export var fog_node_path: NodePath = ""
@export var fog_increase_rate := 0.02
@export var max_fog_density := 0.85

@export var flash_rect: ColorRect
@export var flash_duration := 0.25

# Lighting State Storage
var _original_lighting_color: Color = Color.WHITE
var _original_lighting_alpha: float = 0.0

var zone_a_locked: bool = false
var _garden_state_ready: bool = false


func _ready():
	# 1. CAPTURE ORIGINAL LIGHTING (Dark/Ambient)
	if flash_rect:
		_original_lighting_color = flash_rect.color
		_original_lighting_alpha = flash_rect.modulate.a
		flash_rect.visible = true

	_setup_controller_fallback()
	_connect_treedoors()
	_connect_cicada_timer()
	
	# NOTE: We do NOT start cicadas here anymore. 
	# We wait for _retry_attach_garden_state to ensure variables are synced.

	set_process(true)


func _process(delta):
	_update_fog(delta)


# ---------------------------------------------------------
# GAME CONTROLLER + GARDEN STATE SETUP
# ---------------------------------------------------------
func _setup_controller_fallback():
	if Global.game_controller != null:
		call_deferred("_retry_attach_garden_state")
		return

	var temp_gc := Node.new()
	temp_gc.name = "TempGameController"
	temp_gc.set("garden_state", null)
	get_tree().root.call_deferred("add_child", temp_gc)

	Global.game_controller = temp_gc
	call_deferred("_retry_attach_garden_state")


func _retry_attach_garden_state():
	if _garden_state_ready:
		return

	var gc = Global.game_controller
	if gc == null:
		call_deferred("_retry_attach_garden_state")
		return

	var gs = get_tree().root.find_child("GardenState", true, false)

	if gs:
		gc.set("garden_state", gs)
		_garden_state_ready = true
		print("ZoneA: GardenState attached.")

		# --- FIX: START CICADAS ONLY AFTER STATE IS READY ---
		start_cicadas()

		if gs.has_signal("trunk_swap_triggered"):
			gs.trunk_swap_triggered.connect(_on_trunk_swap_triggered)

		emit_signal("garden_state_ready", gs)
	else:
		call_deferred("_retry_attach_garden_state")


# ---------------------------------------------------------
# TREE DOOR CONNECTION
# ---------------------------------------------------------
func _connect_treedoors():
	for td in get_tree().get_nodes_in_group("treedoor"):
		if td.has_signal("correct_knock"):
			td.correct_knock.connect(_on_correct_knock)
		if td.has_signal("wrong_knock"):
			td.wrong_knock.connect(_on_wrong_knock)


# ---------------------------------------------------------
# CICADA TIMER
# ---------------------------------------------------------
func _connect_cicada_timer():
	if cicada_timer:
		if not cicada_timer.timeout.is_connected(_on_cicada_timer_timeout):
			cicada_timer.timeout.connect(_on_cicada_timer_timeout)


# ---------------------------------------------------------
# CORRECT KNOCK
# ---------------------------------------------------------
func _on_correct_knock(tree):
	# COMMENTED OUT TO ALLOW COLLECTING 5 STICKS
	# if zone_a_locked: return

	var gs = _gs()
	if gs:
		gs.zone_a_completed = true
		gs.total_sticks_collected += 1
		print("ZoneA: Stick collected! Total: ", gs.total_sticks_collected)

	print("ZoneA: Correct knock on", tree.name)

	# zone_a_locked = true # Keep unlocked for testing
	stop_cicadas()

	# FLASH GREEN
	flash_screen(Color(0.2, 1.0, 0.2))


# ---------------------------------------------------------
# WRONG KNOCK
# ---------------------------------------------------------
func _on_wrong_knock(tree):
	print("ZoneA: Wrong knock on", tree.name)

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if player.has_method("apply_sanity_damage"):
			player.apply_sanity_damage(5)
		elif player.has_node("sanity_component"):
			player.get_node("sanity_component").take_damage(5)

	var gs = _gs()
	if gs:
		gs.add_mistake()

	# FLASH RED
	flash_screen(Color(1.0, 0.1, 0.1))


# ---------------------------------------------------------
# CICADA CONTROL
# ---------------------------------------------------------
func start_cicadas():
	var gs = _gs()
	if gs:
		gs.cicadas_active = true

	if cicada_player and not cicada_player.playing:
		cicada_player.play()

	if cicada_timer:
		cicada_timer.start()


func stop_cicadas():
	if cicada_timer:
		cicada_timer.stop()

	var gs = _gs()
	if gs:
		gs.cicadas_active = false

	if cicada_player:
		cicada_player.stop()


func _on_cicada_timer_timeout():
	var gs = _gs()
	if gs:
		gs.cicadas_active = not gs.cicadas_active
		if gs.cicadas_active:
			cicada_player.play()
		else:
			cicada_player.stop()
	else:
		if cicada_player.playing:
			cicada_player.stop()
		else:
			cicada_player.play()


# ---------------------------------------------------------
# FOG CONTROL
# ---------------------------------------------------------
func _update_fog(delta: float) -> void:
	var gs = _gs()
	if gs == null:
		return

	gs.fog_density = clamp(
		gs.fog_density + fog_increase_rate * delta,
		0.0,
		max_fog_density
	)

	if fog_parallax_layer:
		var fog_sprite = fog_parallax_layer.get_node_or_null(fog_node_path)
		if fog_sprite and fog_sprite.material:
			fog_sprite.material.set("shader_parameter/density", gs.fog_density)
		return

	if fog and fog.material:
		fog.material.set("shader_parameter/density", gs.fog_density)


# ---------------------------------------------------------
# FLASH EFFECT (RETURNS TO AMBIENT)
# ---------------------------------------------------------
func flash_screen(target_flash_color: Color) -> void:
	if flash_rect == null:
		return

	# 1. Snap to Flash Color
	flash_rect.visible = true
	flash_rect.color = target_flash_color
	flash_rect.modulate.a = 0.8

	# 2. Tween back to Original Lighting Color
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	
	# Fade Color back to Dark/Ambient
	tween.tween_property(flash_rect, "color", _original_lighting_color, flash_duration)
	
	# Fade Alpha back to Original Ambient Alpha
	tween.tween_property(flash_rect, "modulate:a", _original_lighting_alpha, flash_duration)


# ---------------------------------------------------------
# TRUNK SWAP CALLBACK
# ---------------------------------------------------------
func _on_trunk_swap_triggered(step: int):
	if trunk_textures.is_empty():
		return

	var idx := step % trunk_textures.size()

	for td in get_tree().get_nodes_in_group("treedoor"):
		if td.has_method("apply_trunk_texture"):
			td.apply_trunk_texture(trunk_textures[idx])
		elif td.has_node("Trunk"):
			var sp = td.get_node("Trunk") as Sprite2D
			if sp:
				sp.texture = trunk_textures[idx]


# ---------------------------------------------------------
# HELPERS
# ---------------------------------------------------------
func _gs():
	var gc = Global.game_controller
	if gc == null:
		return null
	return gc.get("garden_state")
