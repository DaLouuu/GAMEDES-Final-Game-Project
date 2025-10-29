class_name GameController
extends Node

@export var gui: Control
@export var world_2d: Node2D  

var player: CharacterBody2D

var curr_2d_scene: Node = null
var curr_gui_scene: Node = null

signal hostiles_toggled(enabled: bool)

# ---------------------------------------
# Initialization
# ---------------------------------------
func _ready() -> void:
	Global.game_controller = self

	await get_tree().process_frame  # wait one frame to let Player load
	player = get_node_or_null("World2D/Player")
	
	if player:
		if not player.is_in_group("Player"):
			player.add_to_group("Player")
	else:
		push_warning("⚠️ Player not found in GameController at startup.")

	change_2d_scene("res://dev/paul's do not touch/test_church.tscn")
	
	add_to_group("game_controller")

# ---------------------------------------
# Scene Management
# ---------------------------------------
func change_gui_scene(_new_scene: String, _load_state: EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:
	# Placeholder for future GUI swapping logic
	return


func change_2d_scene(new_scene: String, _load_state: EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:
	if curr_2d_scene:
		match _load_state:
			EnumsRef.SceneLoadState.DELETE:
				curr_2d_scene.queue_free()
			EnumsRef.SceneLoadState.HIDE:
				curr_2d_scene.visible = false
			EnumsRef.SceneLoadState.REMOVE_HIDDEN:
				gui.remove_child(curr_2d_scene)

	var new_scene_instance = load(new_scene).instantiate()
	world_2d.add_child(new_scene_instance)
	curr_2d_scene = new_scene_instance

	# ---- PLAYER HANDLING ----
	if player:
		# Find the spawn marker in the new scene
		var spawn_marker = new_scene_instance.get_node_or_null("Marker2D-SpawnP")
		if spawn_marker:
			player.global_position = spawn_marker.global_position
			var camera: Camera2D = player.get_node("Camera2D")
			camera.reset_smoothing()
		else:
			push_warning("No Marker2D-SpawnP found in new scene.")
	else:
		push_error("Player not initialized in GameController.")

# ---------------------------------------
# Hostile Management
# ---------------------------------------
func set_hostiles_enabled(enabled: bool) -> void:
	print("Hostiles enabled:", enabled)
	for node in world_2d.get_children():
		if node.is_in_group("Enemies"):
			node.process_mode = Node.PROCESS_MODE_ALWAYS if enabled else Node.PROCESS_MODE_DISABLED

	emit_signal("hostiles_toggled", enabled)

# ---------------------------------------
# Utility Functions
# ---------------------------------------
func heal_player_sanity(amount: int = -1) -> void:
	if not player:
		push_warning("heal_player_sanity() called but player not found.")
		return
	if amount == -1:
		player.sanity = player.max_sanity
	else:
		player.sanity = min(player.sanity + amount, player.max_sanity)
	player.emit_signal("sanity_changed", player.sanity)


func teleport_player_to_marker(marker_name: String) -> void:
	if not player or not curr_2d_scene:
		push_warning("teleport_player_to_marker(): Player or scene missing.")
		return
	var marker = curr_2d_scene.get_node_or_null(marker_name)
	if marker:
		player.global_position = marker.global_position
		print("Teleported player to marker:", marker_name)
	else:
		push_warning("Marker '%s' not found in current scene." % marker_name)
