extends Node2D

@onready var default_coords: Vector2 = $"Marker2D-SpawnP".position
var player : Player

func reset_player():
	Global.game_controller.change_2d_scene("uid://bbim0h8qggemx")

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	player.player_resetted.connect(reset_player)
	$WhiteLady.stop_funcs()

func start_funcs():
	await get_tree().physics_frame
	$WhiteLady.start_funcs()
func _on_area_2d_back_to_room_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_check_from("res://map_phase/houses/house2_room.tscn")


func _on_area_2d_answer_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene("res://map_phase/houses/puzzle_pathways/pathway_3/house_puzzle_vase_3.tscn")
func _on_area_flipped_answer(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_check_from("res://map_phase/houses/puzzle_pathways/pathway_1/house_puzzle_shirt_1.tscn", true)
