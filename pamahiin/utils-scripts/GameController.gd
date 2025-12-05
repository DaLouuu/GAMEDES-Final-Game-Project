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
func startPlayer():
	player.visible = true
	player.trigger_cat_ready()
func triggerStart():
	await get_tree().physics_frame
	startPlayer()
	var new_scene_instance = load("uid://c4psaq201foex").instantiate()
	#var old_scene = curr_2d_scene
	world_2d.add_child(new_scene_instance)
	curr_2d_scene = new_scene_instance

func reset_player_to_scene():
	var spawn_marker = curr_2d_scene.get_node_or_null("Marker2D-SpawnP")

	if spawn_marker:
		player.global_position = spawn_marker.global_position
		#new_scene_instance.add_child(player)
		
		var camera: Camera2D = player.get_node("Camera2D")
		changed_scene_with_character.emit()
		if camera:
			camera.reset_smoothing()
func inCutscene(res : DialogueResource):
	Global.game_controller.player.is_cutscene_controlled = false
func notCutscene(res : DialogueResource):
	Global.game_controller.player.is_cutscene_controlled = true
func gotoMainMenu():
	if curr_2d_scene:
		curr_2d_scene.queue_free()	
	var new_scene_instance = load("uid://bdt62bgxs0isa").instantiate()
	world_2d.add_child(new_scene_instance)
	curr_2d_scene = new_scene_instance	
func _ready() -> void:
	player.visible = false
	# Register controller globally
	await get_tree().physics_frame
	Global.game_controller = self
	await get_tree().physics_frame
	DialogueManager.get_current_scene = func():
		return Global.game_controller.curr_2d_scene

	#change_2d_scene("uid://cyc8laq2oakj0") # WorldMap


	# Instantiate main menu
	var new_scene_instance = load("uid://bdt62bgxs0isa").instantiate()
	world_2d.add_child(new_scene_instance)
	curr_2d_scene = new_scene_instance
	
	# Test and debug
	#startPlayer()
	##change_2d_scene("uid://bbim0h8qggemx") # House final
	#change_2d_scene("uid://dxhni64oxaov4") # Church
	#change_2d_scene("uid://dnvq5fs7tu167")
	#DialogueManager.readyWithController()
	
	
func update_artifactCheck():
	await get_tree().physics_frame
	#Global.artifactCount =0
	#if GameState.HOUSE_ARTIFACT_has_artifact_rosary:
		#Global.artifactCount += 1
	#if GameState.CAVE_has_salt:
		#Global.artifactCount += 1
	#if GameState.CHURCH_has_gotten_water:
		#Global.artifactCount += 1
		#
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
		player.set_collision_layer_value(1, true)
		player.set_collision_layer_value(2, true)
		player.set_collision_layer_value(6, true)
		
		player.set_collision_mask_value(1, true)
		player.set_collision_mask_value(2, true)
		player.set_collision_mask_value(6, true)
		
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
