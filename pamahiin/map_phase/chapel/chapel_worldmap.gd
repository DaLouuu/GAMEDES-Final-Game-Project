extends Node2D


@onready var animPlayer = $"AnimationPlayer"

func open_door():
	animPlayer.play("door_open")
func close_door():
	animPlayer.play("door_close")
	




func _ready() -> void:
	close_door()
	
	
#Door trigger open
func _on_area_2_dcenter_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): # Replace with function body.
		open_door()

# Door trigger exit
func _on_area_2_dcenter_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): # Replace with function body.
		close_door()

# Spawn inside trigger
func _on_area_2_dspawn_inside_detector_body_entered(body: Node2D) -> void:
	Global.game_controller.change_2d_scene("res://map_phase/chapel/chapel_interior.tscn")
