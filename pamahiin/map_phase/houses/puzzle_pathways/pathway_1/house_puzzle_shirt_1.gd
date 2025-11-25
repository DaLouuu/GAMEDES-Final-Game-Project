extends Node2D

@onready var default_coords: Vector2 = $"Marker2D-SpawnP".position



func toggle_GlobalState(item: InvItem):
	GameState.HOUSE_read_first_item_puzzle = true
func start_funcs():
	$WhiteLady.start_funcs()
	$WhiteLady2.start_funcs()
	$WhiteLady3.start_funcs()
	
	
func _ready():
	$WhiteLady.stop_funcs()
	$WhiteLady2.stop_funcs()
	$WhiteLady3.stop_funcs()
	
	$"Puzzle/ItemTemplate-Shirt".item_inspected.connect(toggle_GlobalState)
	$"Puzzle/ItemTemplate-Bullets".item_inspected.connect(toggle_GlobalState)
	$"Puzzle/ItemTemplate-Vase".item_inspected.connect(toggle_GlobalState)
	$"PathWayTp/Area2D-Block2/CollisionShape2D".disabled = false
	
func _on_area_2d_back_to_room_body_entered(body: Node2D) -> void:
	print("Shirt back to room")
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_check_from("res://map_phase/houses/house2_room.tscn")
func _on_area_2d_answer_body_entered(body: Node2D) -> void:
	print("Right answer")
	
	$"PathWayTp/Area2D-Block2/CollisionShape2D".disabled = true
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene("res://map_phase/houses/puzzle_pathways/pathway_2/house_puzzle_bullets_2.tscn")


func _on_area_flipped_answer(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_check_from("res://map_phase/houses/house2_room.tscn")
