class_name ChapelCandle
extends StaticBody2D
signal interacted
signal lights_off
@onready var anim_player : AnimationPlayer = $AnimationPlayer
var is_player_in_area : bool = false
var player : CharacterBody2D

func _ready():
	anim_player.animation_finished.connect(lights_off_emit)
	anim_player.play("slowly_fading fire")
func _process(_delta):
	if is_player_in_area and Input.is_action_just_pressed("interact"):
		interacted.emit()
		anim_player.play("slowly_fading fire")

func lights_off_emit():
	lights_off.emit()
	play_stop()
func play_stop():
	await get_tree().physics_frame
	anim_player.seek(20)
	self.modulate = Color(1,1,1)
	
func _on_area_2d_interactable_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		is_player_in_area = true
		player = body	
		$TextureRect.visible = true


func _on_area_2d_interactable_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		is_player_in_area = false
		player = null	
		$TextureRect.visible = false
