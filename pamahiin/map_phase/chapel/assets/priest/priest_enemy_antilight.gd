extends Enemy
func sprite_to_closed_arms():
	$Sprite2D.frame = 0
func play_priest_attack():
	animation_player.play("attack_mode")
