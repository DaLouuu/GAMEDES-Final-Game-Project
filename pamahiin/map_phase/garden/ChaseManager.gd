extends Node
class_name GardenChaseManager

# ---------------------------------------------------------
# EXPORTED VARIABLES
# ---------------------------------------------------------

@export var chase_timer: Timer
@export var gate_exit_area: Area2D

@export var tilemap_layer: TileMapLayer           # TileMapLayer for gate visuals
@export var gate_positions: Array[Vector2i] = []  # Tile coordinates of the gate tiles
@export var closed_gate_id: int = -1              # Source ID of CLOSED gate tile
@export var open_gate_id: int = -1                # Source ID of OPEN gate (grass) tile

@export var duwende_scene: PackedScene
@export var spawn_points: Array[Node2D] = []      # Verified Node2D type

var chase_active: bool = false
var spawned_duwendes: Array = []


# ---------------------------------------------------------
# START CHASE
# ---------------------------------------------------------
func start_chase() -> void:
	if chase_active:
		return

	chase_active = true

	close_gate()
	_spawn_chase_duwendes()

	# Start timer
	if chase_timer:
		chase_timer.start()
		if not chase_timer.timeout.is_connected(_on_timer_fail):
			chase_timer.timeout.connect(_on_timer_fail, CONNECT_ONE_SHOT)

	# Connect exit trigger
	if gate_exit_area and not gate_exit_area.body_entered.is_connected(_on_gate_exit):
		gate_exit_area.body_entered.connect(_on_gate_exit)

	print("[CHASE] Chase started!")


# ---------------------------------------------------------
# SPAWN DWENDES
# ---------------------------------------------------------
func _spawn_chase_duwendes() -> void:
	var gs := get_tree().get_first_node_in_group("GardenState")

	var mistakes: int = 0
	if gs:
		mistakes = int(gs.mistake_count)

	var count: int = max(1, mistakes)
	print("[CHASE] Spawning %s dwendes..." % count)

	if spawn_points.is_empty():
		push_warning("GardenChaseManager: No spawn points found!")
		return

	for i in range(count):
		var spawn_point: Node2D = spawn_points[i % spawn_points.size()]
		var d = duwende_scene.instantiate()
		d.global_position = spawn_point.global_position
		add_child(d)
		spawned_duwendes.append(d)


# ---------------------------------------------------------
# ESCAPE SUCCESS
# ---------------------------------------------------------
func _on_gate_exit(body: Node) -> void:
	if not chase_active: return
	if not body.is_in_group("Player"): return

	chase_active = false

	if chase_timer:
		chase_timer.stop()

	# Remove all spawned dwendes
	for d in spawned_duwendes:
		if is_instance_valid(d):
			d.queue_free()
	spawned_duwendes.clear()

	open_gate()

	# Success dialogue
	var dlg := load("res://dialogues/garden/final_garden.dialogue")
	if dlg:
		DialogueManager.show_dialogue_balloon(dlg, "escape_success")
		await DialogueManager.dialogue_ended

	print("[CHASE] Player escaped successfully!")


# ---------------------------------------------------------
# FAIL CONDITION (timer expired)
# ---------------------------------------------------------
func _on_timer_fail() -> void:
	if not chase_active:
		return

	chase_active = false
	close_gate()

	var dlg := load("res://dialogues/garden/final_garden.dialogue")
	if dlg:
		DialogueManager.show_dialogue_balloon(dlg, "escape_fail")
		await DialogueManager.dialogue_ended

	print("[CHASE] Player failed to escape.")


# ---------------------------------------------------------
# TILEMAP LAYER GATE CONTROL
# ---------------------------------------------------------
func open_gate() -> void:
	if tilemap_layer == null:
		push_warning("Gate open failed: tilemap_layer not assigned.")
		return

	for cell in gate_positions:
		tilemap_layer.set_cell(
			cell,               # Vector2i tile position
			open_gate_id,       # Source ID (GRASS tile)
			Vector2i.ZERO,      # Atlas coord
			0                   # Alternative tile
		)

	print("[CHASE] Gate opened.")


func close_gate() -> void:
	if tilemap_layer == null:
		push_warning("Gate close failed: tilemap_layer not assigned.")
		return

	for cell in gate_positions:
		tilemap_layer.set_cell(
			cell,               # Vector2i tile position
			closed_gate_id,     # Source ID (GATE tile)
			Vector2i.ZERO,
			0
		)

	print("[CHASE] Gate closed.")
