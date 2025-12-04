extends Node2D
@onready var cave_marker = $"Marker2D-CaveOut"
var player : Player = null
func _enter_tree() -> void:
	await get_tree().physics_frame
	player  = get_tree().get_first_node_in_group("Player")
	if player:
		player.scale = Vector2(1.0,1.0)
		player.camera.zoom = Vector2(2.0,2.0)
		player.move_speed = 250
		player.sprint_multiplier = 1.8
		player.turnOnLight()


func _ready() -> void:
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.CAVE] = cave_marker
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.H1] = $"Marker2D-H1"
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.H2] = $"Marker2D-H2"
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.CHAPEL_EXIT1] = $"Marker2D-Left"
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.CHAPEL_EXIT2] = $"Marker2D-Mid"
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.CHAPEL_EXIT3] = $"Marker2D-Right"

		
func getCustomMarker(type :EnumsRef.LOCAL_FROM_TYPE) -> Marker2D:
	return GameState.dict_TPs[type]
	
func gotoCave():
	Global.game_controller.change_2d_scene("uid://dnvq5fs7tu167")

func _on_area_2d_cave_entrance_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/CAVE_cave_done.dialogue"))
		
