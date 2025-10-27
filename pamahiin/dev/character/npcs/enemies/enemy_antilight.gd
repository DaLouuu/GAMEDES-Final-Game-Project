class_name Enemy
extends CharacterBody2D

signal begin_behaviors
signal stop_behaviors


@export var move_speed: float = 200.0
@export var detection_radius: float = 120.0
@export var wander_interval: float = 2.0
@onready var PlayerDetector: Area2D = $PlayerDetector
@onready var vision_ray : RayCast2D = $VisionRay

func start_funcs():
	begin_behaviors.emit()
func stop_funcs():
	stop_behaviors.emit()
		
func _physics_process(delta: float) -> void:
	
	if velocity.length() > 0:
		$AnimationPlayer.play("walk_right")
		
		
	if velocity.x > 0:
		#$Sprite2D.flip_h = false
		scale.x = -4
		
	else:
		#$Sprite2D.flip_h = true
		scale.x = 4
		

	move_and_slide()
	
