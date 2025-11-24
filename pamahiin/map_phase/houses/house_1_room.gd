extends Node2D

var locationType : EnumsRef.LocationType = EnumsRef.LocationType.HOME

func getLocationType()->EnumsRef.LocationType:
	return locationType
	
	
func _on_area_2d_to_room_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene("res://map_phase/houses/puzzle_pathways/pathway_1/house_puzzle_shirt_1.tscn")


func _on_area_2d_back_to_world_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_check_from("res://map_phase/houses/house1.tscn")
