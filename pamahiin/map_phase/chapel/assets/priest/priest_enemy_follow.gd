extends EnemyFollow
var player_hits = true
func hitPlayer():
	# Theres two types of damage currently HitEffectPoison and HitEffectDamage		
	if enemy.global_position.distance_to(player.global_position) < hit_distance:
		player.ReceiveSanityDamage(damage_to_player, hit_effect_type)
	
	if $"../../AudioStreamPlayer".playing:
		return

	$"../../AudioStreamPlayer".play()
		
