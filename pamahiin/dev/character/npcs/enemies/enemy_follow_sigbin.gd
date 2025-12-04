extends EnemyFollow
var is_attacking = false
func Enter():
	await get_tree().physics_frame
	enemy.state_machine.travel("Walk")
	move_behavior = enemy.move_behavior
	hit_distance = enemy.hit_distance
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
		#else:
			#if enemy.global_position.distance_to(player.global_position) < detection_radius:
				#has_clear_sight = true	


	# --- Behavior logic ---
	if has_clear_sight:
		# Reset lose timer since player is visible
		lose_timer = 0.0
		
		# Movement
		var move_vec = move_behavior.get_move_vector(enemy,player,delta)
		enemy.animation_tree.set("parameters/Walk/blend_position", move_vec)
		enemy.animation_tree.set("parameters/Idle/blend_position", move_vec)
		enemy.animation_tree.set("parameters/Attack/blend_position", move_vec)
		
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
		if is_attacking:
			pass
		else:
			$"../../Timer-AttackLength".start()
			enemy.state_machine.travel("Attack")
			is_attacking = true
			player.ReceiveSanityDamage(damage_to_player, hit_effect_type)		

		
func Exit() -> void:
	is_attacking = false
	enemy.velocity = Vector2.ZERO
	enemy.state_machine.travel("Idle")
	

func _on_timer_attack_length_timeout() -> void:
		is_attacking = false
		enemy.state_machine.travel("Walk")
	
