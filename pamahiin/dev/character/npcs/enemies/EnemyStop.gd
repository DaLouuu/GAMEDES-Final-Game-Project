class_name EnemyStop extends State

func Enter():
	await  get_tree().physics_frame
	enemy.collision_shape.disabled = true
	enemy.begin_behaviors.connect(transitionBackToIdle)
	enemy.stop_behaviors.connect(transitionBackToStop)
func transitionBackToStop():
	Transitioned.emit(self, "EnemyStop")	
	
func transitionBackToIdle():
	enemy.collision_shape.disabled = false
	Transitioned.emit(self, "EnemyIdle")
		
func Update(delta:float):
	pass
	
func Physics_Update(_delta:float):
	pass
