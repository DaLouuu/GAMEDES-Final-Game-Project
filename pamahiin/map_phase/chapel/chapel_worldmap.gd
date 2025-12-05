extends Node2D


@onready var animPlayer = $"AnimationPlayer"
var chapelInterior = preload("uid://dxhni64oxaov4")
func open_door():
	animPlayer.play("door_open")
func close_door():
	animPlayer.play("door_close")
	

		
func getCustomMarker(type :EnumsRef.LOCAL_FROM_TYPE) -> StringName:
	return GameState.dict_TPs[type]


func _ready() -> void:
	close_door()

	 
	  
	
#Door trigger open
func _on_area_2_dcenter_body_entered(body: Node2D) -> void:
	if Global.artifactCount < 3:
		return
	if body.is_in_group("Player"): # Replace with function body.
		open_door()

# Door trigger exit
func _on_area_2_dcenter_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): # Replace with function body.
		close_door()

# Spawn inside trigger
func _on_area_2_dspawn_inside_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): # Replace with function body.
		#Global.game_controller.change_2d_scene_custom("res://map_phase/chapel/chapel_interior.tscn", EnumsRef.LOCAL_FROM_TYPE.CHAPEL_ENTER2)
		
		if Global.artifactCount < 3:
			DialogueManager.show_dialogue_balloon(load("res://dialogue/CHURCH_locked_outside.dialogue"))
			return
		Global.game_controller.change_2d_scene("res://map_phase/chapel/chapel_interior.tscn")
		

func _on_area_2_drightdoor_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): # Replace with function body.
		#Global.game_controller.change_2d_scene_custom("res://map_phase/chapel/chapel_interior.tscn", EnumsRef.LOCAL_FROM_TYPE.CHAPEL_ENTER3)
		Global.game_controller.change_2d_scene("res://map_phase/chapel/chapel_interior.tscn")
		


func _on_area_2_dleftdoor_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): # Replace with function body.
		#Global.game_controller.change_2d_scene_custom("res://map_phase/chapel/chapel_interior.tscn", EnumsRef.LOCAL_FROM_TYPE.CHAPEL_ENTER1)
		Global.game_controller.change_2d_scene("res://map_phase/chapel/chapel_interior.tscn")
		
