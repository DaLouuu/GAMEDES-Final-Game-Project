extends Area2D

var is_player_in_body : bool = false
var popup : CanvasLayer


func show_popup():
	popup = load("res://map_phase/houses/assets/House 1/popup_scene.tscn").instantiate()
	get_tree().current_scene.add_child(popup)
	DialogueManager.show_example_dialogue_balloon(
		load("res://dialogue/house_dialogues/inspect_paper_clue.dialogue"),
        "start"
	)
	$"../AudioStreamPlayer2D".play(2.78)

func _ready():
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	
func _on_dialogue_ended(state):
	if popup:
		popup.close()
		popup = null

func _process(_delta: float) -> void:
	if(is_player_in_body and Input.is_action_just_pressed("interact")):
		show_popup()
	
func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		is_player_in_body = true


func _on_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		is_player_in_body = false
