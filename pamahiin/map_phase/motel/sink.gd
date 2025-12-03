extends StaticBody2D
var is_player_in_area = false
var is_interacting = false
var player = null

const _DIALOGUE = preload("uid://duly5xo31nudh")


func _ready():
	$SinkArea.body_entered.connect(_on_area_2d_body_entered)
	$SinkArea.body_exited.connect(_on_area_2d_body_exited)
	pass
	
func _process(_delta):
	if is_player_in_area and Input.is_action_just_pressed("interact") and not is_interacting:
		start_interaction()

func start_interaction():
	is_interacting = true 
	player.is_cutscene_controlled = true
	
	DialogueManager.show_example_dialogue_balloon(_DIALOGUE)
	await DialogueManager.dialogue_ended
	
	player.is_cutscene_controlled = false
	is_interacting = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		is_player_in_area = true
		player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		is_player_in_area = false
		player = null
