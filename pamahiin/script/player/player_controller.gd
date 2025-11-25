extends CharacterBody2D

@export var move_speed: float = 120.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var _last_dir: Vector2 = Vector2.DOWN  # remembers last facing direction

func _physics_process(delta: float) -> void:
	var input_vec := Vector2.ZERO
	input_vec.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vec.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if input_vec.length() > 0.0:
		input_vec = input_vec.normalized()
		velocity = input_vec * move_speed
		_last_dir = input_vec
		_play_walk_animation(input_vec)
	else:
		velocity = Vector2.ZERO
		_play_idle_animation()

	move_and_slide()


func _play_walk_animation(dir: Vector2) -> void:
	# Decide which axis is dominant
	if abs(dir.x) > abs(dir.y):
		# Horizontal movement
		if dir.x > 0.0:
			anim.play("walk_right")
		else:
			anim.play("walk_left")
	else:
		# Vertical movement
		if dir.y > 0.0:
			anim.play("walk_down")
		else:
			anim.play("walk_up")


func _play_idle_animation() -> void:
	# Use the last direction we moved in
	if abs(_last_dir.x) > abs(_last_dir.y):
		if _last_dir.x > 0.0:
			anim.play("idle_right")
		else:
			anim.play("idle_left")
	else:
		if _last_dir.y > 0.0:
			anim.play("idle_down")
		else:
			anim.play("idle_up")
