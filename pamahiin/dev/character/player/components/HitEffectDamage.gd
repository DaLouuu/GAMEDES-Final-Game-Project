class_name HitEffectDamage
extends HitEffect

func apply(damage: float, player:Player) -> void:

		
	player.sanity_damaged.connect(player.camera.start_shake)
	# Clamping restricts between 0 and max sanity value
	player.sanity = clamp(player.sanity - damage, 0, player.max_sanity)

	print("💢 Player sanity now:", player.sanity)
	player.sanity_changed.emit(player.sanity)
	player.sanity_damaged.emit()
	player.is_invulnerable = true
	player.invul_timer.start()
	player.sanity_damaged.disconnect(player.camera.start_shake)
	
