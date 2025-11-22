extends Node2D


func _on_area_2d_back_to_room_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_check_from("res://map_phase/houses/house1_room.tscn")


func _on_area_2d_answer_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene("res://map_phase/houses/puzzle_pathways/pathway_3/house_puzzle_vase_3.tscn")
