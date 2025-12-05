extends EnemyFollow
func Enter() -> void:
	

	move_behavior = enemy.move_behavior
	detection_radius = enemy.detection_radius
	hit_effect_type = enemy.hit_effect_type
	damage_to_player = enemy.damage_to_player
	print("Enemy following player.")
	lose_timer = 0.0

func Physics_Update(delta: float) -> void:
	if not player or not enemy:
		return

	var has_clear_sight := true
	
	vision_ray.look_at(player.global_position)
	vision_ray.force_raycast_update()
	
	
	# VisionRay Collision Logic
	if vision_ray.is_colliding():
		var collider = vision_ray.get_collider()
		#print("Hit:", collider)
		if collider and collider.is_in_group("EnemyVisionBlock"):
			has_clear_sight = false



					
	# --- Behavior logic ---
	if has_clear_sight:
		# Reset lose timer since player is visible
		lose_timer = 0.0
		
		# Movement
		var move_vec = move_behavior.get_move_vector(enemy,player,delta)
		enemy.velocity = move_vec
		#enemy.move_and_slide()
		enemy.move_and_collide(enemy.velocity * delta)
		

	else:
		# Can't see player, count up timer
		
		lose_timer += delta
		#print("Can't see player: ", lose_timer)
		
		if lose_timer >= lost_threshold:
			Transitioned.emit(self, "EnemyIdle")
			#print("Lost sight of player — switching to idle.")
			
	
	# Theres two types of damage currently HitEffectPoison and HitEffectDamage		
	if enemy.global_position.distance_to(player.global_position) < hit_distance:
		player.ReceiveSanityDamage(damage_to_player, hit_effect_type)		

func Exit() -> void:
	enemy.velocity = Vector2.ZERO
