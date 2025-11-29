extends Node2D

@onready var area = $StaticBody2D/Area2D
@onready var scene_cam = $SceneCamera
@onready var animation_player = $AnimationPlayer
@onready var collision = $"Bathroom Door/DoorCollision"
@onready var door_prox = $"Bathroom Door/DoorArea"
@onready var closet_prox = $"Closet/ClosetArea"

var player: Node = null
var _camera_active := false
var dialogue_done = false
var animation_done = false
var closet_interaction = false

const _MOTEL_PART1 = preload("uid://k0tnwhe1st87")
const _MOTEL_PART2 = preload("uid://bb3b8vv05lb22")
const _MOTEL_PART3 = preload("uid://duolgm7dnpwi4")

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	
	if player:
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
			
		door_prox.body_entered.connect(_on_body_entered)
		door_prox.body_exited.connect(_on_body_exited)
			
		# play motel cutscene part 1
		animation_player.play("motel_introduction_part1")
		DialogueManager.show_dialogue_balloon(_MOTEL_PART1)
		await DialogueManager.dialogue_ended
		
		# play motel cutscene part 2
		animation_player.play("motel_introduction_part2")
		await get_tree().create_timer(5.52).timeout
		DialogueManager.show_dialogue_balloon(_MOTEL_PART2)
		await DialogueManager.dialogue_ended
		
		animation_player.play("motel_introduction_part3")
		DialogueManager.show_dialogue_balloon(_MOTEL_PART3)
		await DialogueManager.dialogue_ended
		
		animation_player.play("motel_introduction_cutscene_release")
		
		player.is_motel_introduction = false
		player.is_cutscene_controlled = false
		
func _on_body_entered(body):
	if body.is_in_group("Player"):
		collision.set_deferred("disabled", true)
		$"Bathroom Door/Sprite2D".set_deferred("visible", false)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		collision.set_deferred("disabled", false)
		$"Bathroom Door/Sprite2D".set_deferred("visible", true)

# use only if no dialogue after playing animation
func _on_animation_finished(animation_name: String):
	if animation_name == "motel_introduction_part2":
		player.is_cutscene_controlled = false
		player.get_node("CanvasLayer").show()
		

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
