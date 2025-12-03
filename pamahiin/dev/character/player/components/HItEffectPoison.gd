class_name HitEffectPoison
extends HitEffect

@export var poison_duration: float = 3.0

var elapsed := 0.0

func apply(damage: float, player: Player) -> void:
	var poison = PoisonProcess.new()
	
	# Process pattern loop to connect back to camera, emmit that im damaged, say im invulnerable for further stacking
	player.sanity_damaged.connect(player.camera.start_shake)
	player.sanity_damaged.emit()
	player.is_invulnerable = true
	player.invul_timer.start()
	player.sanity_damaged.disconnect(player.camera.start_shake)
	
	poison.init(player, poison_duration, damage)
	player.add_child(poison)

	
class PoisonProcess extends Node:
	var player: CharacterBody2D
	var duration: float
	var damage: float
	var elapsed: float = 0.0
	
	func init(_player, _duration, _damage):
		player = _player
		duration = _duration
		damage = _damage
	
	func _process(delta):
		if not is_instance_valid(player):
			queue_free()
			return

		elapsed += delta
		var poison_damage = (damage / duration) * delta

		player.sanity = clamp(player.sanity - poison_damage, 0, player.max_sanity)
		player.sanity_changed.emit(player.sanity)
		player.sanity_damaged.emit()

		if elapsed >= duration:
			queue_free()
