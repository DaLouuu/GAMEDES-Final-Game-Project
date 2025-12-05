extends Sprite2D

var is_player_in_range : bool

func _get_player() -> Player:
	if not is_inside_tree():
		return
	
	var player := get_tree().get_first_node_in_group("Player")
	assert(player != null, "No player in scene!")
	return player

func _process(_delta: float) -> void:
	var player := _get_player()
	
	if not player.is_cutscene_controlled and is_player_in_range and Input.is_action_just_pressed("interact"):
		player.is_cutscene_controlled = true
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/house_dialogues/old_lady_at_house/old_lady_greets.dialogue"), "start")
		await DialogueManager.dialogue_ended
		player.is_cutscene_controlled = false
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		is_player_in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		is_player_in_range = false
