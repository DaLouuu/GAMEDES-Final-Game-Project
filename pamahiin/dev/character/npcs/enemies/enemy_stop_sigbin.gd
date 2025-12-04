extends EnemyStop

func Enter():
	await get_tree().physics_frame
	enemy.collision_shape.set_disabled(true)
	enemy.begin_behaviors.connect(transitionBackToIdle)
	enemy.stop_behaviors.connect(transitionBackToStop)
