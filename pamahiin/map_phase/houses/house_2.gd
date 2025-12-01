extends Node2D
@export var backFromPosition: Vector2 = Vector2(194.25, 297.0)
@onready var houseDoor : Sprite2D  = $HouseParts/House2Door


	
func goto_coming_out_from_spawn() -> void:
	houseDoor.play_close()

func _on_area_2d_sound_trigger_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		houseDoor.play_open()

func _on_area_2d_sound_trigger_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		houseDoor.play_close()
		


func _on_area_2d_to_room_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and GameState.HOUSE_has_met_ghost_girl:
		Global.game_controller.change_2d_scene("res://map_phase/houses/house2_room.tscn")
	elif body.is_in_group("Player"):
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/HOUSE_dialogue_outside.dialogue"))
		
