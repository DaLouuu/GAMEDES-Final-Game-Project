extends Area2D

var is_player_in_body : bool = false
var popup : CanvasLayer
var original_scale : Vector2
@onready var sprite_2d : Sprite2D = $".."

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
	original_scale = sprite_2d.scale
	

# Enlarges and increases saturation
func enlarge_upon_near():
	if sprite_2d:
		var tween = create_tween()
		tween.tween_property(sprite_2d, "scale", sprite_2d.scale * 1.1, 0.2)

# Resets to original scale and saturation
func reset_state():
	if sprite_2d:
		var tween = create_tween()
		tween.tween_property(sprite_2d, "scale", original_scale, 0.2)

func _on_dialogue_ended(state):
	GameState.HOUSE_has_read_clue = true
	if popup:
		popup.close()
		popup = null

func _process(_delta: float) -> void:
	if(is_player_in_body and Input.is_action_just_pressed("interact")):
		show_popup()
	
func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		is_player_in_body = true
		if $"../TextureRect":
			$"../TextureRect".visible = true
		enlarge_upon_near()


func _on_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		is_player_in_body = false
		if $"../TextureRect":
			$"../TextureRect".visible = false
		reset_state()

func _on_mouse_entered() -> void:
	enlarge_upon_near()


func _on_mouse_exited() -> void:
	reset_state()
