extends Node
class_name GardenChaseManager

# ---------------------------------------------------------
# GATE SETTINGS
# ---------------------------------------------------------
@export_group("Gate Configuration")
@export var gate_layer: TileMapLayer              
@export var gate_sfx: AudioStreamPlayer           

@export_group("Intro Settings")
@export var intro_entry_area: Area2D              

# ---------------------------------------------------------
# CHASE SETTINGS
# ---------------------------------------------------------
@export_group("Chase Configuration")
@export var chase_timer: Timer
@export var gate_exit_area: Area2D                
@export var duwende_scene: PackedScene
@export var spawn_points: Array[Node2D] = []      
@export var tension_sfx: AudioStreamPlayer        
@export var tension_threshold: float = 10.0       

# ---------------------------------------------------------
# ENDING UI
# ---------------------------------------------------------
@export_group("Ending UI")
@export var ending_canvas: CanvasLayer            
@export var ending_texture_rect: TextureRect      
@export var win_image: Texture2D                  
@export var lose_image: Texture2D                 

var chase_active: bool = false
var intro_active: bool = false
var spawned_duwendes: Array = []
var _tension_active: bool = false

func _ready():
	add_to_group("GardenChaseManager")
	
	if ending_canvas: 
		ending_canvas.visible = false
	
	if gate_exit_area:
		if not gate_exit_area.body_entered.is_connected(_on_gate_exit):
			gate_exit_area.body_entered.connect(_on_gate_exit)
			
	if intro_entry_area:
		intro_entry_area.body_entered.connect(_on_intro_entry)

func _process(_delta):
	if chase_active and chase_timer and not chase_timer.is_stopped():
		if chase_timer.time_left <= tension_threshold and not _tension_active:
			_start_tension_effects()

# ---------------------------------------------------------
# GATE CONTROL
# ---------------------------------------------------------
func set_gate(is_open: bool):
	if gate_layer == null: 
		print("GardenChaseManager: Gate Layer not assigned!")
		return
	
	if gate_sfx: 
		gate_sfx.play()
	
	if is_open:
		gate_layer.visible = false
		gate_layer.collision_enabled = false
	else:
		gate_layer.visible = true
		gate_layer.collision_enabled = true

# ---------------------------------------------------------
# INTRO SEQUENCE
# ---------------------------------------------------------
func trigger_intro_gate_sequence():
	if intro_active or chase_active: return
	intro_active = true
	
	set_gate(true)
	
	if intro_entry_area == null:
		await get_tree().create_timer(4.0).timeout
		_close_intro_gate()

func _on_intro_entry(body: Node):
	if not intro_active or chase_active: return
	if body.is_in_group("Player"):
		_close_intro_gate()

func _close_intro_gate():
	intro_active = false
	set_gate(false)
	var dlg = load("res://map_phase/garden/Dialogue/garden_final.dialogue")
	if dlg:
		DialogueManager.show_dialogue_balloon(dlg, "gate_closes_scared")

# ---------------------------------------------------------
# CHASE LOGIC
# ---------------------------------------------------------
func start_chase() -> void:
	if chase_active: return
	chase_active = true
	print("[CHASE] STARTED")

	set_gate(true)

	var dlg = load("res://map_phase/garden/Dialogue/garden_final.dialogue")
	if dlg:
		DialogueManager.show_dialogue_balloon(dlg, "chase_start_warning")
		await DialogueManager.dialogue_ended

	_spawn_chase_duwendes()

	var zone_a = get_tree().get_first_node_in_group("ZoneAController")
	if zone_a: zone_a.start_continuous_shake(3.0) 

	if chase_timer:
		chase_timer.start()
		if not chase_timer.timeout.is_connected(_on_timer_fail):
			chase_timer.timeout.connect(_on_timer_fail, CONNECT_ONE_SHOT)

func _spawn_chase_duwendes() -> void:
	var mistakes = 0
	var gs_candidates = get_tree().get_nodes_in_group("GardenState")
	for c in gs_candidates:
		if c.get("mistake_count") != null:
			mistakes = c.mistake_count
			break
	
	var count = max(4, mistakes)
	
	if spawn_points.is_empty(): return
	for i in range(count):
		var pt = spawn_points[i % spawn_points.size()]
		if duwende_scene:
			var d = duwende_scene.instantiate()
			d.global_position = pt.global_position
			get_tree().current_scene.call_deferred("add_child", d)
			spawned_duwendes.append(d)

func _start_tension_effects():
	_tension_active = true
	if tension_sfx: tension_sfx.play()
	
	var zone_a = get_tree().get_first_node_in_group("ZoneAController")
	if zone_a:
		var tween = create_tween().set_loops()
		tween.tween_callback(func(): zone_a.flash_screen(Color(1, 0, 0, 0.4))).set_delay(0.5)

# ---------------------------------------------------------
# ENDINGS
# ---------------------------------------------------------
func _on_gate_exit(body: Node) -> void:
	if not chase_active: return
	if body.is_in_group("Player"):
		_trigger_ending(true) # WIN

func _on_timer_fail() -> void:
	if not chase_active: return
	_trigger_ending(false) # LOSE

func _trigger_ending(is_win: bool):
	chase_active = false
	if chase_timer: chase_timer.stop()
	
	# 1. Stop Sounds
	if tension_sfx: tension_sfx.stop()
	if gate_sfx: gate_sfx.stop()
	
	# 2. Cleanup Environment
	var zone_a = get_tree().get_first_node_in_group("ZoneAController")
	if zone_a: 
		var t = zone_a.create_tween()
		t.kill() 
		zone_a.cleanup_for_ending()
	
	# 3. CLEANUP PLAYER (Hide and Invulnerable)
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if "is_invulnerable" in player: player.is_invulnerable = true
		player.visible = false  # <--- HIDE PLAYER HERE
		
		# Hide UI
		var ui = player.get_node_or_null("CanvasLayer")
		if ui: ui.visible = false
	
	# 4. Despawn Enemies
	for d in spawned_duwendes:
		if is_instance_valid(d): d.queue_free()
	spawned_duwendes.clear()

	# 5. Show Image
	if ending_canvas and ending_texture_rect:
		ending_canvas.visible = true
		ending_texture_rect.texture = win_image if is_win else lose_image
	
	# 6. Dialogue & Scene Change
	var dlg = load("res://map_phase/garden/Dialogue/garden_final.dialogue")
	if dlg:
		var branch = "ending_good" if is_win else "ending_bad"
		DialogueManager.show_dialogue_balloon(dlg, branch)
		await DialogueManager.dialogue_ended
		
		if is_win:
			get_tree().change_scene_to_file("res://map_phase/world_map.tscn")
		else:
			# Optional: Reload scene on loss?
			# get_tree().reload_current_scene()
			pass
