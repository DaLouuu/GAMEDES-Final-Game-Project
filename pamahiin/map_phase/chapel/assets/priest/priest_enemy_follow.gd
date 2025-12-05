extends EnemyFollow
var player_hits = true
func Enter() -> void:
	await get_tree().physics_frame
	$"../../AnimationPlayer".play("attack_mode_from_chase")
	move_behavior = enemy.move_behavior
	hit_distance = enemy.hit_distance
	detection_radius = enemy.detection_radius
	hit_effect_type = enemy.hit_effect_type
	damage_to_player = enemy.damage_to_player
	print("Enemy following player.")
	lose_timer = 0.0
func hitPlayer():
	# Theres two types of damage currently HitEffectPoison and HitEffectDamage		
	if enemy.global_position.distance_to(player.global_position) < hit_distance:

		player.ReceiveSanityDamage(damage_to_player, hit_effect_type)
	
	if $"../../AudioStreamPlayer".playing:
		return

	$"../../AudioStreamPlayer".play()
		
