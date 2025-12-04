class_name GameController
extends Node

signal changed_scene_with_character

@export var gui: Control
@export var world_2d: Node2D  

enum AUDIO_PLAY {CHASE_HOUSE}
@onready var player: Player = $"Player"

var curr_2d_scene: Node = null
var curr_gui_scene: Node = null




var audioDictionary: Dictionary[AUDIO_PLAY, Resource] = {
	AUDIO_PLAY.CHASE_HOUSE: preload("uid://bc7c7kecbm4bl"),
}


var garden_state: Node = null

func triggerStart():
	await get_tree().physics_frame
	player.visible = true
	var new_scene_instance = load("uid://c4psaq201foex").instantiate()
	#var old_scene = curr_2d_scene
	world_2d.add_child(new_scene_instance)
	curr_2d_scene = new_scene_instance
func setupPlayer(_player_: Player):
	player = Player.new()
	player.collect(load("res://dev/resource_scripts/inventory/items/lantern.tres"))
func _ready() -> void:
	player.visible = false
	# Register controller globally
	await get_tree().physics_frame
	Global.game_controller = self
	await get_tree().physics_frame
	DialogueManager.get_current_scene = func():
		return Global.game_controller.curr_2d_scene
	#player.artifact_collect.connect(Global.game_controller.updateArtifactCount)
	#DialogueManager.show_dialogue_balloon(load("res://dialogue/test.dialogue"), "start")
	#change_2d_scene("res://dev/paul's do not touch/test_church.tscn")
	#change_2d_scene("res://map_phase/houses/puzzle_pathways/pathway_1/house_puzzle_shirt_1.tscn")
	#change_2d_scene("res://map_phase/chapel/chapel_worldmap.tscn")
	#change_2d_scene("res://map_phase/houses/house_together.tscn")
	var new_scene_instance = load("uid://bdt62bgxs0isa").instantiate()
	#var old_scene = curr_2d_scene
	world_2d.add_child(new_scene_instance)
	curr_2d_scene = new_scene_instance
	#change_2d_scene("uid://cyc8laq2oakj0") # WorldMap
	#change_2d_scene("res://map_phase/cave/Cave.tscn")
  # Try to attach GardenState if current scene has one
	#_find_and_set_garden_state()

	# TEMPORARY: load your debugging scene
	# change_2d_scene("res://dev/dana's_testing_stuff/garden_phase.tscn")


func update_artifactCheck():
	Global.artifactCount =0
	if GameState.HOUSE_ARTIFACT_has_artifact_rosary:
		Global.artifactCount += 1
	if GameState.CAVE_has_salt:
		Global.artifactCount += 1
func play_curr_global_audio(playType : AUDIO_PLAY):
	if audioDictionary.has(playType):
		AudioManager.music_player.stream = audioDictionary[playType]
		AudioManager.music_player.play()
func getCurrScene():
	return curr_2d_scene

func stop_curr_global_audio():
	AudioManager.music_player.stop()

func presetup():
	pass

func change_2d_scene_custom(new_scene: String, localFromType : EnumsRef.LOCAL_FROM_TYPE, load_state : EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:
	presetup()
	# Placeholder: implement GUI scene swapping later
	var promiseToFree = false
	if curr_2d_scene:
		match load_state:
			
			EnumsRef.SceneLoadState.DELETE:
				promiseToFree = true
				curr_2d_scene.queue_free()
				
			EnumsRef.SceneLoadState.HIDE:
				curr_2d_scene.visible = false
			EnumsRef.SceneLoadState.REMOVE_HIDDEN:
				gui.remove_child(curr_2d_scene)
			_:
				print("Error: Load state specified is undefined in EnumsRef")
	var new_scene_instance = load(new_scene).instantiate()
	#var old_scene = curr_2d_scene
	world_2d.add_child(new_scene_instance)
	curr_2d_scene = new_scene_instance
	
		# ---- PLAYER HANDLING ----
	if player:
		# Find the spawn marker in the new scene
		var mark : Marker2D = null
		if curr_2d_scene.has_method("getCustomMarker"):
			mark = curr_2d_scene.getCustomMarker(localFromType)
		if mark:
			
			player.global_position = mark.global_position
			#new_scene_instance.add_child(player)
			
			var camera : Camera2D = player.get_node("Camera2D")
			changed_scene_with_character.emit()
			if new_scene_instance.has_method("goto_coming_out_from_spawn"):
				new_scene_instance.goto_coming_out_from_spawn()
			# Smoothing makes it so the camera doesn't auto pan to player and showing movement
			camera.reset_smoothing()
		else:
			push_warning("No Marker2D-SpawnP found in new scene.")

			
				
	else:
		push_error("Player not initialized in GameController.")
	#if promiseToFree:
		#old_scene.queue_free()
		
	
	
		
func change_gui_scene(new_scene: String, load_state : EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:
	# Placeholder: implement GUI scene swapping later
	
	
	return

func change_2d_scene_check_from(new_scene: String, startFuncs = false, isComingOut = true, load_state : EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:
	presetup()
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

	#_after_scene_loaded(new_scene_instance)

	# --- PLAYER HANDLING ---
	if player:
		var spawn_marker = new_scene_instance.get_node_or_null("Marker2D-OutFromP")
		if spawn_marker:
			
			if new_scene_instance.has_method("start_funcs") and startFuncs:
				new_scene_instance.start_funcs()
			player.global_position = spawn_marker.global_position
			#new_scene_instance.add_child(player)
			
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
	presetup()
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

	#_after_scene_loaded(new_scene_instance)

	# --- PLAYER HANDLING ---
	if player:
		var spawn_marker = new_scene_instance.get_node_or_null("Marker2D-SpawnP")

		if spawn_marker:
			
			
			player.global_position = spawn_marker.global_position
			#new_scene_instance.add_child(player)
			
			var camera: Camera2D = player.get_node("Camera2D")
			changed_scene_with_character.emit()
			if camera:
				camera.reset_smoothing()
		else:
			push_warning("No Marker2D-SpawnP found in scene.")
	else:
		push_error("Player not initialized in GameController.")
