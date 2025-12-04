extends Enemy
func _physics_process(delta: float) -> void:
	
	if velocity.length() > 0:
		
		$AnimationPlayer.play("walk_right")
		

		

	move_and_slide()
	
