extends Node2D

var _has_entered_main_room := false

@export var move_duration := 10
@export var rest_point: Marker2D

@onready var _end_entrance_shadow: Sprite2D = $Areas/EndEntrance/Shadow

const _CAVE_ENDING_DIALOGUE = preload("uid://cploqh0i3n2c5")

func _on_main_entrance_body_entered(body: Node2D) -> void:
	if not is_instance_of(body, CharacterBody2D):
		return
	
	# TODO: Bring player outside, back to the world map

func _on_end_entrance_body_entered(body: Node2D) -> void:
	if not is_instance_of(body, Player):
		return
	
	var player: Player = body
	
	if not _has_entered_main_room:
		_has_entered_main_room = true
		
		await player.lerp_towards(rest_point, move_duration)
		
		player.is_cutscene_controlled = true
		DialogueManager.show_dialogue_balloon(_CAVE_ENDING_DIALOGUE)
		await DialogueManager.dialogue_ended
		player.is_cutscene_controlled = false
		
		_end_entrance_shadow.visible = true
	else:
		# TODO: Bring player outside, back to the world map
		pass
	
