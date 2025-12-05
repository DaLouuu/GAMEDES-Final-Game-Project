extends Node2D

@onready var default_coords: Vector2 = $"Marker2D-SpawnP".position
@onready var itemKey = $ItemTemplate
var player : Player

var locationType : EnumsRef.LocationType = EnumsRef.LocationType.HOME

func getLocationType()->EnumsRef.LocationType:
	return locationType

func reset_player():
	Global.game_controller.change_2d_scene("uid://bbim0h8qggemx")

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	player.player_resetted.connect(reset_player)
	$"Puzzle/ItemTemplate-Key".item_collected.connect(jumpscare_node)

	
func jumpscare_node(item:InvItem):
	print("boo")
	GameState.HOUSE_has_gotten_house_key = true
	var rect := $CanvasLayer/TextureRect
	rect.visible = true
	rect.modulate.a = 1.0
	rect.scale = Vector2.ONE

	# Create tween
	var t := create_tween()
	t.set_parallel(true)  # run effects simultaneously
	$AudioStreamPlayer2D.volume_db=10
	$AudioStreamPlayer2D.play(15.33)
	

	# Rapid scale jitter (shake effect)
	t.tween_property(rect, "scale", Vector2(1.1, 0.9), 0.05).as_relative()
	t.tween_property(rect, "scale", Vector2(0.9, 1.1), 0.05).as_relative()
	t.tween_property(rect, "scale", Vector2(1.05, 1.05), 0.05).as_relative()
	t.tween_property(rect, "scale", Vector2(0.95, 0.95), 0.05).as_relative()
	Global.game_controller.play_curr_global_audio(GameController.AUDIO_PLAY.CHASE_HOUSE)
	# Slow zoom-in over 1 second
	t.tween_property(rect, "scale", Vector2(1.5, 1.5), 1.0)
	
	# Hide after 1 second
	await get_tree().create_timer(1.0).timeout
	$WhiteLady.start_funcs()
	$WhiteLady.visible = true
	rect.visible = false
	$"Area2D-BackToRoom2".queue_free()
	$"Area2D-BackToRoom3".queue_free()

	rect.queue_free()
func _on_area_2d_back_to_room_body_entered(body: Node2D) -> void:
	$AudioStreamPlayer2D.stop()
	if body.is_in_group("Player") and GameState.HOUSE_has_gotten_house_key:
		GameState.HOUSE_seen_key_but_did_not_pickup = false
		Global.game_controller.change_2d_scene_check_from("res://map_phase/houses/puzzle_pathways/pathway_3/house_puzzle_vase_3.tscn", true)
		
	elif body.is_in_group("Player") and not GameState.HOUSE_has_gotten_house_key:
		GameState.HOUSE_seen_key_but_did_not_pickup = true
		Global.game_controller.change_2d_scene_check_from("res://map_phase/houses/house2_room.tscn")
		
		
func _on_Timer_timeout():
	pass
