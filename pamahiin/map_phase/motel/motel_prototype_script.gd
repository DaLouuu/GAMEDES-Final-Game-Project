extends Node2D

@onready var area = $StaticBody2D/Area2D
@onready var scene_cam = $SceneCamera
@onready var animation_player = $AnimationPlayer
@onready var collision = $"Bathroom Door/DoorCollision"
@onready var door_prox = $"Bathroom Door/DoorArea"
@onready var blackscreen = $BlackScreen/ColorRect

var player: Node = null
var _camera_active := false
var dialogue_done := false
var animation_done := false

const _MOTEL_PART1 = preload("uid://qscn1pg3v58k")
const _MOTEL_PART2_1 = preload("uid://basb5dp8egkf4")
const _MOTEL_PART2_2 = preload("uid://cb1gpmdjgasxv")
const _MOTEL_PART2_3 = preload("uid://cma0agl0v02ey")
const _MOTEL_PART3 = preload("uid://duolgm7dnpwi4")
const _MOTEL_PART4 = preload("uid://bkwn606josp6m")
const _CHURCH_DIALOGUE = preload("uid://cpipx4msue08b")
const _BURIAL_DIALOGUE = preload("uid://q26y70q2mork")
const _GRAVEYARD_DIALOGUE = preload("uid://bbqvi23sbe1fp")
const _PREWORLDMAP_DIALOGUE = preload("uid://ceyiyty5lfndm")
const _WORLDMAP_DIALOGUE = preload("uid://bhrgm6uea2hwl")

func _ready() -> void:
	await get_tree().physics_frame
	player = get_tree().get_first_node_in_group("Player")
	door_prox.body_entered.connect(_on_body_entered)
	door_prox.body_exited.connect(_on_body_exited)
	$outside.body_entered.connect(_go_outside)
	$Paper.item_inspected.connect(_on_inspect)
	$Closet/ItemTemplate.item_inspected.connect(_on_inspect)
	$Cabinet/ItemTemplate.item_inspected.connect(_on_inspect)
	$Sink/ItemTemplate.item_inspected.connect(_on_inspect)
	$Bathtub/ItemTemplate.item_inspected.connect(_on_inspect)
	$Toilet/ItemTemplate.item_inspected.connect(_on_inspect)
	
	if player:
		var pl = player as Player
		pl.camera.make_current()
		player.is_cutscene_controlled = true
		player.is_motel_introduction = true
		
		# remove sanity ui
		if (player.get_node("CanvasLayer")):
			player.get_node("CanvasLayer").hide()
		
		# zoom in player cam for motel part
		var player_cam = player.get_node("Camera2D")
		if player_cam:
			player_cam.zoom = Vector2(1.75, 1.75)
			_camera_active = true

		## story context introduction
		#await get_tree().create_timer(2.0).timeout
		#$WhistleBGM.play()
		#await story_context_display("story_img1", true, 4.0)
		#DialogueManager.show_example_dialogue_balloon(_CHURCH_DIALOGUE)
		#await DialogueManager.dialogue_ended
		#await story_context_display("story_img1", false, 1.5)
		#await story_context_display("story_img2", true, 1.5)
		#DialogueManager.show_example_dialogue_balloon(_BURIAL_DIALOGUE)
		#await DialogueManager.dialogue_ended
		#await story_context_display("story_img2", false, 1.5)
		#await story_context_display("story_img3", true, 1.5)
		#DialogueManager.show_example_dialogue_balloon(_GRAVEYARD_DIALOGUE)
		#await DialogueManager.dialogue_ended
		#await story_context_display("story_img3", false, 1.5)
		#DialogueManager.show_example_dialogue_balloon(_PREWORLDMAP_DIALOGUE)
		#await DialogueManager.dialogue_ended
		#await story_context_display("story_img4", true, 1.5)
		#DialogueManager.show_example_dialogue_balloon(_WORLDMAP_DIALOGUE)
		#await DialogueManager.dialogue_ended
		#await story_context_display("story_img4", false, 1.5)
		#
		#
		#$WhistleBGM.stop()
		# play motel cutscene part 1
		$Paper.set_deferred("visible", false)
		animation_player.play("motel_introduction_part1")
		await get_tree().create_timer(2.0).timeout
		blackscreen_set(0.0,1.0)
		await get_tree().create_timer(1.0).timeout
		DialogueManager.show_example_dialogue_balloon(_MOTEL_PART1)
		await DialogueManager.dialogue_ended
	
		# play motel cutscene part 2
		animation_player.play("motel_introduction_part2")
		await get_tree().create_timer(5.52).timeout
		DialogueManager.show_example_dialogue_balloon(_MOTEL_PART2_1)
		$toothbrushing.play()
		await DialogueManager.dialogue_ended
		$toothbrushing.stop()
		await story_context_display("story_img6", true, 0.5)
		$toothdrop.play()
		await story_context_display("story_img7", true, 0.3)
		$toothdrop.play()
		await story_context_display("story_img8", true, 0.5)
		$toothdrop.play()
		await story_context_display("story_img9", true, 0.4)
		await get_tree().create_timer(1.0).timeout
		await story_context_display("story_img6", false, 0.0)
		await story_context_display("story_img7", false, 0.0)
		await story_context_display("story_img8", false, 0.0)
		await story_context_display("story_img9", false, 0.0)
		await get_tree().create_timer(1.0).timeout
		DialogueManager.show_example_dialogue_balloon(_MOTEL_PART2_2)
		await DialogueManager.dialogue_ended
		
		await story_context_display("story_img10", true, 0.0)
		$jumpscaresfx.play()
		blackscreen_set(1.0,0.0)
		await get_tree().create_timer(2.0).timeout
		DialogueManager.show_example_dialogue_balloon(_MOTEL_PART2_3)
		await DialogueManager.dialogue_ended
		# await story_context_display("story_img10", false, 0.0)
		await get_tree().create_timer(2.0).timeout
		
		## play motel cutscene part 3
		$Paper.set_deferred("visible", true)
		animation_player.play("motel_introduction_part3")
		blackscreen_set(0.0,3.0)
		DialogueManager.show_example_dialogue_balloon(_MOTEL_PART3)
		await DialogueManager.dialogue_ended

		## play motel cutscene part 4
		animation_player.play("motel_introduction_part4")
		await animation_player.animation_finished
		DialogueManager.show_example_dialogue_balloon(_MOTEL_PART4)
		await DialogueManager.dialogue_ended
		
		animation_player.play("motel_introduction_cutscene_release")
		animation_player.animation_finished.connect(_on_animation_finished)
		
		player.is_motel_introduction = false
		player.is_cutscene_controlled = false
		
func _on_body_entered(body):
	if body.is_in_group("Player"):
		collision.set_deferred("disabled", true)
		$"Bathroom Door/Sprite2D".set_deferred("visible", false)
		$"dooropen".play()

func _on_body_exited(body):
	if body.is_in_group("Player"):
		collision.set_deferred("disabled", false)
		$"Bathroom Door/Sprite2D".set_deferred("visible", true)
		$"doorclose".play()

func _go_outside(body):
	if body.is_in_group("Player") and not player.is_cutscene_controlled:
		Global.game_controller.player.trigger_cat_ready()
		Global.game_controller.change_2d_scene("res://map_phase/world_map.tscn")
		

# use only if no dialogue after playing animation
func _on_animation_finished(animation_name: String):
	if animation_name == "motel_introduction_cutscene_release":
		player.is_cutscene_controlled = false
		player.get_node("CanvasLayer").show()
	
func _on_inspect(body):
	player.is_cutscene_controlled = true
	await DialogueManager.dialogue_ended
	player.is_cutscene_controlled = false
	
func story_context_display(sprite_name : String, display : bool, duration : float) -> void:
	var tween = create_tween()
	var blackscreenlayer = $BlackScreen
	
	if (display):
		tween.tween_property(blackscreenlayer.get_node(sprite_name), "modulate:a", 1.0, duration)
	else:
		tween.tween_property(blackscreenlayer.get_node(sprite_name), "modulate:a", 0.0, duration) 
		
	await get_tree().create_timer(duration).timeout
	
func blackscreen_set(target_alpha: float, duration: float) -> void:
	var tween = create_tween()
	tween.tween_property(blackscreen, "modulate:a", target_alpha, duration)
	await tween.finished
	
func zoom_jumpscare() -> void:
	var tween_zoom = create_tween()
	tween_zoom.tween_property($BlackScreen/story_img10,"scale", Vector2(3.0,3.0), 0.3)
	await tween_zoom.finished
	story_context_display("story_img10",false,0.0)
	$mirrorglassbreak.play()
	blackscreen_set(1.0, 0.0)

		

		
#func _on_body_entered(body: Node2D) -> void:
	#if not body.is_in_group("Player"):
		#return
#
	#player = body  # reference the existing player
#
	## Disable player's camera
	#var player_cam = player.get_node("Camera2D")
	#if player_cam:
		#player_cam.zoom = Vector2(1.5,1.5)
#
	#_camera_active = true
#
	#print("Motel camera active!")
