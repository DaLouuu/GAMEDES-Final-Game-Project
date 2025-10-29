class_name Enemy
extends CharacterBody2D

@export var move_speed: float = 60
@export var detection_radius: float = 120.0
@export var wander_interval: float = 2.0


func _physics_process(delta: float) -> void:
	move_and_slide()
	
	if velocity.length() > 0:
		$AnimationPlayer.play("walk_right")
	if velocity.x > 0:
		$Sprite2D.flip_h = false
	else:
		$Sprite2D.flip_h = true
