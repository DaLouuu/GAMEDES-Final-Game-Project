class_name GameController
extends Node

signal changed_scene_with_character

@export var gui: Control
@export var world_2d: Node2D  

@onready var player: CharacterBody2D = $"Player"

var locationType: EnumsRef.LocationType = EnumsRef.LocationType.HOME
var curr_2d_scene: Node = null
var curr_gui_scene: Node = null

var garden_state: Node = null



func _ready() -> void:
	# Register controller globally
	Global.game_controller = self

	# Try to attach GardenState if current scene has one
	_find_and_set_garden_state()

	# TEMPORARY: load your debugging scene
	change_2d_scene("res://dev/dana's_testing_stuff/garden_phase.tscn")



# -----------------------------------------------------------------------------
#   GARDEN STATE SETUP
# -----------------------------------------------------------------------------

func _find_and_set_garden_state():
	# Case 1 — direct child in current scene
	if has_node("GardenState"):
		garden_state = get_node("GardenState")
		return

	# Case 2 — search entire tree (GardenState placed deeper)
	var gs = get_tree().root.find_child("GardenState", true, false)
	if gs:
		garden_state = gs
	else:
		push_warning("GameController: GardenState not found in current scene.")


func _after_scene_loaded(new_scene: Node):
	# First check inside the scene
	var gs = new_scene.get_node_or_null("GardenState")

	if gs:
		garden_state = gs
	else:
		# Try searching globally
		_find_and_set_garden_state()



# -----------------------------------------------------------------------------
#   GUI SCENE SWITCHING (placeholder)
# -----------------------------------------------------------------------------

func change_gui_scene(_new_scene: String, _load_state: EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:
	return



# -----------------------------------------------------------------------------
#   SCENE SWITCHING: CHECK-FROM VERSION
# -----------------------------------------------------------------------------

func change_2d_scene_check_from(new_scene: String, _isComingOut := true, load_state: EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:

	if curr_2d_scene:
		match load_state:
			EnumsRef.SceneLoadState.DELETE:
				curr_2d_scene.queue_free()
			EnumsRef.SceneLoadState.HIDE:
				curr_2d_scene.visible = false
			EnumsRef.SceneLoadState.REMOVE_HIDDEN:
				gui.remove_child(curr_2d_scene)

	var new_scene_instance = load(new_scene).instantiate()
	world_2d.add_child(new_scene_instance)
	curr_2d_scene = new_scene_instance

	_after_scene_loaded(new_scene_instance)

	# --- PLAYER HANDLING ---
	if player:
		var spawn_marker = new_scene_instance.get_node_or_null("Marker2D-OutFromP")

		if spawn_marker:
			if new_scene_instance.has_method("getLocationType"):
				locationType = new_scene_instance.getLocationType()

			player.changeFootstepSound()
			player.global_position = spawn_marker.global_position

			var camera: Camera2D = player.get_node("Camera2D")
			changed_scene_with_character.emit()

			if new_scene_instance.has_method("goto_coming_out_from_spawn"):
				new_scene_instance.goto_coming_out_from_spawn()

			camera.reset_smoothing()
		else:
			push_warning("No Marker2D-OutFromP found in new scene.")
	else:
		push_error("Player not initialized in GameController.")



# -----------------------------------------------------------------------------
#   STANDARD SCENE SWITCHING
# -----------------------------------------------------------------------------

func change_2d_scene(new_scene: String, load_state: EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:

	if curr_2d_scene:
		match load_state:
			EnumsRef.SceneLoadState.DELETE:
				curr_2d_scene.queue_free()
			EnumsRef.SceneLoadState.HIDE:
				curr_2d_scene.visible = false
			EnumsRef.SceneLoadState.REMOVE_HIDDEN:
				gui.remove_child(curr_2d_scene)

	var new_scene_instance = load(new_scene).instantiate()
	world_2d.add_child(new_scene_instance)
	curr_2d_scene = new_scene_instance

	_after_scene_loaded(new_scene_instance)

	# --- PLAYER HANDLING ---
	if player:
		var spawn_marker = new_scene_instance.get_node_or_null("Marker2D-SpawnP")

		if spawn_marker:
			if new_scene_instance.has_method("getLocationType"):
				locationType = new_scene_instance.getLocationType()

			player.changeFootstepSound()
			player.global_position = spawn_marker.global_position

			var camera: Camera2D = player.get_node("Camera2D")
			changed_scene_with_character.emit()

			camera.reset_smoothing()
		else:
			push_warning("No Marker2D-SpawnP found in scene.")
	else:
		push_error("Player not initialized in GameController.")
