extends CharacterBody2D
@export var move_speed : float =  100
@export var sprint_multiplier : float = 1.8

const SPEED = 300.0
const PUSH_FORCE = 100.0
const MIN_PUSH_FORCE = 100.0

# Anything moving and colliding is always under the collision
func _physics_process(_delta: float) -> void:
	# Smart logic cancelling inputs of both directional keys
	var input_direction := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up") 
	)

	# Sprinting multiplier
	var current_speed := move_speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier
	
	velocity = input_direction * current_speed
	
	move_and_slide()
