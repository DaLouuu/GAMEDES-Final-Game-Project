class_name GameController
extends Node

@export var gui: Control
@export var world_2d: Node2D  


@onready var player: CharacterBody2D = $"Player"

var curr_2d_scene: Node = null
var curr_gui_scene: Node = null

func _ready() -> void:
	Global.game_controller = self

	DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "start")
	#change_2d_scene("res://dev/paul's do not touch/test_church.tscn")
		
		
func change_gui_scene(new_scene: String, load_state : EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:
	# Placeholder: implement GUI scene swapping later
	
	
	return


func change_2d_scene(new_scene: String, load_state : EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:
	if curr_2d_scene:
		if EnumsRef.SceneLoadState.DELETE:
			curr_2d_scene.queue_free()
		elif EnumsRef.SceneLoadState.HIDE:
			curr_2d_scene.visible = false
		elif EnumsRef.SceneLoadState.REMOVE_HIDDEN:
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
			var camera : Camera2D = player.get_node("Camera2D")
			camera.reset_smoothing()			

		else:
			push_warning("No Marker2D-SpawnP found in new scene.")
	else:
		push_error("Player not initialized in GameController.")
