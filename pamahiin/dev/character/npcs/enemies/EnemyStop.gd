class_name EnemyStop extends State

func Enter():
	enemy.begin_behaviors.connect(transitionBackToIdle)
	enemy.stop_behaviors.connect(transitionBackToStop)
	
func transitionBackToStop():
	Transitioned.emit(self, "EnemyStop")	
	
func transitionBackToIdle():
	Transitioned.emit(self, "EnemyIdle")
		
func Update(delta:float):
	pass
	
func Physics_Update(_delta:float):
	pass
