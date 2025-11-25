extends Sprite2D

var is_player_in_range : bool


func _process(_delta: float) -> void:
	if is_player_in_range and Input.is_action_just_pressed("interact"):
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/house_dialogues/old_lady_at_house/old_lady_greets.dialogue"), "start")
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		is_player_in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		is_player_in_range = false
