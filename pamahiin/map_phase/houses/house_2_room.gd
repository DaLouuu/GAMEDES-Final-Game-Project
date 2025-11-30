extends Node2D
var locationType : EnumsRef.LocationType = EnumsRef.LocationType.HOME
@onready var tileMap:TileMap = $TileMap
@export var backFromPosition: Vector2 = Vector2(194.25, 297.0)

func getTileMap()->TileMap:
	return tileMap
func getLocationType()->EnumsRef.LocationType:
	return locationType

func _ready() -> void:
	Global.game_controller.stop_curr_global_audio()
func _on_area_2d_to_room_body_entered(body: Node2D) -> void:
	if GameState.HOUSE_has_met_ghost_girl == false or GameState.HOUSE_has_read_clue == false:
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/house_dialogues/player_enter_puzzle.dialogue"))
		return
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene("res://map_phase/houses/puzzle_pathways/pathway_1/house_puzzle_shirt_1.tscn")



func _on_area_2d_back_to_world_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_custom("res://map_phase/houses/house_together.tscn", EnumsRef.LOCAL_FROM_TYPE.H2)
