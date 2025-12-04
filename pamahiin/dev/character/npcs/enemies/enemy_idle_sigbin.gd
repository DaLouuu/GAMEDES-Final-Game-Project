extends EnemyIdle
func randomize_wander():
	
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(wander_minTime,wander_maxTime)
	enemy.animation_tree.set("parameters/Walk/blend_position", move_direction)
	enemy.animation_tree.set("parameters/Idle/blend_position", move_direction)

func Enter():
	print("Idle Mode")
	enemy.state_machine.travel("Walk")
	move_speed = enemy.move_speed

	player_detector.body_entered.connect(_on_body_entered)
	randomize_wander()	
