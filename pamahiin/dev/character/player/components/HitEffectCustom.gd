class_name HitEffectCustom
extends HitEffect

func apply(damage: float, player:CharacterBody2D) -> void:
	player.sanity = clamp(player.sanity - damage, 0, player.max_sanity)

	print("💢 Player sanity now:", player.sanity)
	player.sanity_changed.emit(player.sanity)
	player.sanity_damaged.emit()
	
	player.is_invulnerable = true
	player.invul_timer.start()
	
