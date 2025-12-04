extends Node2D

@onready var default_coords: Vector2 = $"Marker2D-SpawnP".position
var isLadyStart = false
var player : Player

func reset_player():
	Global.game_controller.change_2d_scene("uid://bbim0h8qggemx")

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	player.player_resetted.connect(reset_player)
	if not isLadyStart:
		$AudioStreamPlayer2D.play()
func start_funcs():
	
	await get_tree().physics_frame
	$WhiteLady.start_funcs()
	isLadyStart = true
func _on_area_2d_back_to_room_body_entered(body: Node2D) -> void:
	await get_tree().physics_frame
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


func _on_area_2d_stop_sound_body_entered(_body: Node2D) -> void:
	$AudioStreamPlayer2D.stop()


func _on_area_2d_play_glass_body_entered(_body: Node2D) -> void:
	print("Playing the sound")
	$AudioStreamPlayer2D.play()
