extends EnemyIdle
func randomize_wander():
	
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(wander_minTime,wander_maxTime)

func Enter():
	move_speed = enemy.move_speed

	player_detector.body_entered.connect(_on_body_entered)
	randomize_wander()	
	

	
	
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		vision_ray.look_at(player.global_position)
		vision_ray.force_raycast_update()
		var hit = vision_ray.get_collider()
		if hit and hit.is_in_group("EnemyVisionBlock"):
			return
		else:
			Transitioned.emit(self, "EnemyFollow")
			

	
		
func Update(delta:float):
	var overlapping = player_detector.get_overlapping_bodies()
	
	if overlapping.size() > 0:
		for b in overlapping:
			if b.is_in_group("Player"):
				_on_body_entered(b)
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()
func Physics_Update(_delta:float):
	if not enemy || not player:
		return
	#  Update ray direction toward player
		
	enemy.velocity = move_direction * move_speed
