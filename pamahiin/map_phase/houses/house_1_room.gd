extends Node2D


@export var backFromPosition = Vector2(249, 334)

var locationType : EnumsRef.LocationType = EnumsRef.LocationType.HOME

func getLocationType()->EnumsRef.LocationType:
	return locationType
	
	
func _on_area_2d_to_room_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene("res://map_phase/houses/puzzle_pathways/pathway_1/house_puzzle_shirt_1.tscn")


func _on_area_2d_back_to_world_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_custom("res://map_phase/houses/house_together.tscn", EnumsRef.LOCAL_FROM_TYPE.H1)
