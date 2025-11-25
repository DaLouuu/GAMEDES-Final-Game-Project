class_name GameController
extends Node

signal changed_scene_with_character

@export var gui: Control
@export var world_2d: Node2D  

@onready var player: CharacterBody2D = $"Player"

var curr_2d_scene: Node = null
var curr_gui_scene: Node = null
var garden_state: Node = null   # <-- Added

func _ready() -> void:
	Global.game_controller = self
	change_2d_scene("res://dev/paul's do not touch/test_church.tscn")


func change_gui_scene(new_scene: String, load_state: EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:
	# Placeholder: implement GUI scene swapping later
	return


func change_2d_scene(new_scene: String, load_state: EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:

	# ---------------------------
	# CLEAN UP PREVIOUS SCENE
	# ---------------------------
	if curr_2d_scene:
		match load_state:
			EnumsRef.SceneLoadState.DELETE:
				curr_2d_scene.queue_free()
			EnumsRef.SceneLoadState.HIDE:
				curr_2d_scene.visible = false
			EnumsRef.SceneLoadState.REMOVE_HIDDEN:
				gui.remove_child(curr_2d_scene)
			_:
				print("Error: Load state specified is undefined in EnumsRef")


	# ---------------------------
	# LOAD NEW SCENE
	# ---------------------------
	var new_scene_instance = load(new_scene).instantiate()
	world_2d.add_child(new_scene_instance)
	curr_2d_scene = new_scene_instance

	# ---------------------------
	# GARDEN STATE HANDLING
	# ---------------------------

	# Check if the new scene path contains "garden"
	if "garden" in new_scene.to_lower():
		
		# Create GardenState if not yet present
		if not garden_state:
			garden_state = load("res://scripts/garden/GardenState.gd").new()
			add_child(garden_state)
			print("GardenState initialized.")
		
		# Reset variables every time the garden scene loads
		garden_state.reset()

	else:
		# Leaving the garden — clean up GardenState
		if garden_state:
			garden_state.queue_free()
			garden_state = null
			print("GardenState removed.")


	# ---------------------------
	# PLAYER SPAWN HANDLING
	# ---------------------------
	if player:
		var spawn_marker = new_scene_instance.get_node_or_null("Marker2D-SpawnP")
		if spawn_marker:
			player.global_position = spawn_marker.global_position

			var camera: Camera2D = player.get_node("Camera2D")
			changed_scene_with_character.emit()

			# Reset camera smoothing so it doesn't slide across map
			camera.reset_smoothing()
			
		else:
			push_warning("No Marker2D-SpawnP found in new scene.")
	else:
		push_error("Player not initialized in GameController.")
