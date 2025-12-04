extends StaticBody2D
var is_player_in_area = false
var player = null

const _DIALOGUE = preload("uid://duolgm7dnpwi4")


func _ready():
	#$ClosetArea.body_entered.connect(_on_area_2d_body_entered)
	#$ClosetArea.body_exited.connect(_on_area_2d_body_exited)
	pass
	
func _process(_delta):
	if is_player_in_area and Input.is_action_just_pressed("interact"):
		DialogueManager.show_dialogue_balloon(_DIALOGUE)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		is_player_in_area = true
		player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		is_player_in_area = false
		player = null
