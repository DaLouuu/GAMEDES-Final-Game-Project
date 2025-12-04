extends Node2D


@export var backFromPosition = Vector2(249, 334)

var locationType : EnumsRef.LocationType = EnumsRef.LocationType.HOME

func _ready() -> void:
	if GameState.HOUSE_has_chest_opened:
		if $LittleGirl:
			$LittleGirl.queue_free()
	if $LittleGirl:
		$Chest.chest_opened.connect($LittleGirl.free_npc)
func obtainItemArtifact():
	GameState.HOUSE_ARTIFACT_has_artifact_rosary = true
	var player = get_tree().get_first_node_in_group("Player")
	player.collect(load("uid://b2t3hhapem6qe"))
	
func getLocationType()->EnumsRef.LocationType:
	return locationType
func playTreasureOpen():
	$"AudioStreamPlayer2D-open".play()
	GameState.HOUSE_has_chest_opened = true
func playObtainedItem():
	$"AudioStreamPlayer2D-GottenItem".play()
	
func _on_area_2d_to_room_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene("res://map_phase/houses/puzzle_pathways/pathway_1/house_puzzle_shirt_1.tscn")


func _on_area_2d_back_to_world_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_custom("uid://cyc8laq2oakj0", EnumsRef.LOCAL_FROM_TYPE.H1)
