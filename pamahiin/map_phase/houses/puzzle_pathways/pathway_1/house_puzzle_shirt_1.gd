extends Node2D

@onready var default_coords: Vector2 = $"Marker2D-SpawnP".position
@onready var move_timer = $"Timer2-MoveTimer"
var is_moving_up = false
var minTime = 3.0
var maxTime = 8.0
var isLadySpawns = false
var player : Player
func toggle_GlobalState(_item: InvItem):
	GameState.HOUSE_read_first_item_puzzle = true
func start_funcs():
	await get_tree().physics_frame
	$WhiteLady.start_funcs()
	$WhiteLady2.start_funcs()
	$WhiteLady3.start_funcs()
	
func player_reset():
	Global.game_controller.change_2d_scene("uid://bbim0h8qggemx")
func _ready():
	player = get_tree().get_first_node_in_group("Player")
	player.player_resetted.connect(player_reset)
	$WhiteLady.stop_funcs()
	$WhiteLady2.stop_funcs()
	$WhiteLady3.stop_funcs()
	
	$"Puzzle/ItemTemplate-Shirt".item_inspected.connect(toggle_GlobalState)
	$"Puzzle/ItemTemplate-Bullets".item_inspected.connect(toggle_GlobalState)
	$"Puzzle/ItemTemplate-Vase".item_inspected.connect(toggle_GlobalState)
	$"PathWayTp/Area2D-Block2/CollisionShape2D".disabled = false
	if !isLadySpawns:
		$Timer.start(randf_range(minTime,maxTime))
	
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
		GameState.HOUSE_finished_puzzle = true
		Global.game_controller.change_2d_scene_check_from("res://map_phase/houses/house2_room.tscn")


func _on_timer_timeout() -> void:
	$AudioStreamPlayer2D.play()

func _physics_process(delta: float) -> void:
	if is_moving_up and $WhiteLady4:
		$WhiteLady4.position.y -= 200 *delta
func _on_area_2d_body_entered(_body: Node2D) -> void:
	if GameState.HOUSE_has_seen_white_lady and $WhiteLady4:
		$WhiteLady4.queue_free()
		return
	is_moving_up = true
	move_timer.start()
	GameState.HOUSE_has_seen_white_lady = true

func _on_timer_2_move_timer_timeout() -> void:
	is_moving_up = false
	if $WhiteLady4:
		$WhiteLady4.queue_free()
	
