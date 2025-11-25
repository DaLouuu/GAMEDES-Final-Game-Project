extends Node2D

@onready var default_coords: Vector2 = $"Marker2D-SpawnP".position
func _ready():
	$WhiteLady.stop_funcs()

func start_funcs():
	$WhiteLady.start_funcs()
func _on_area_2d_back_to_room_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_check_from("res://map_phase/houses/house2_room.tscn")


func _on_area_2d_answer_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene("res://map_phase/houses/puzzle_pathways/final/house_puzzle_final.tscn")

func _on_area_flipped_answer(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_check_from("res://map_phase/houses/puzzle_pathways/pathway_2/house_puzzle_bullets_2.tscn", true)

func _on_area_2d_block_3_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
