extends Node2D
@onready var cave_marker = $"Marker2D-CaveOut"
var player : Player
func _enter_tree() -> void:
	await get_tree().physics_frame
	player  = get_tree().get_first_node_in_group("Player")
	player.scale = Vector2(1.0,1.0)
	player.camera.zoom = Vector2(0.2,0.2)
	player.move_speed = 200
	player.sprint_multiplier = 1.8



func _ready() -> void:
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.CAVE] = cave_marker
	
		
func getCustomMarker(type :EnumsRef.LOCAL_FROM_TYPE) -> Marker2D:
	return GameState.dict_TPs[type]
func _on_area_2d_cave_entrance_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene("uid://dnvq5fs7tu167")
