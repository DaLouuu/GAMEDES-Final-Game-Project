extends Node2D

@onready var houseDoor : Sprite2D  = $HouseParts/House2Door

var locationType : EnumsRef.LocationType = EnumsRef.LocationType.WORLD

func getLocationType()->EnumsRef.LocationType:
	return locationType
func goto_coming_out_from_spawn() -> void:
	houseDoor.play_close()

func _on_area_2d_sound_trigger_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		houseDoor.play_open()

func _on_area_2d_sound_trigger_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		houseDoor.play_close()
		


func _on_area_2d_to_room_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene("res://map_phase/houses/house2_room.tscn")
