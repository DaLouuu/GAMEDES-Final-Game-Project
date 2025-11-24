extends StaticBody2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer
var is_player_in_area : bool = false
var player : CharacterBody2D

func _ready():
	anim_player.play("slowly_fading fire")
	
func _process(_delta):
	if is_player_in_area and Input.is_action_just_pressed("interact"):
		anim_player.play("slowly_fading fire")



func _on_area_2d_interactable_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		is_player_in_area = true
		player = body	
	


func _on_area_2d_interactable_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		is_player_in_area = false
		player = null	
