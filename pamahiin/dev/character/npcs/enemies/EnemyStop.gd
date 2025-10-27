class_name EnemyStop extends State

func Enter():
	enemy = $"../.."
	enemy.begin_behaviors.connect(transitionBackToIdle)
	pass			
		
func transitionBackToIdle():
	Transitioned.emit(self, "EnemyIdle")
		
func Update(delta:float):
	pass
	
func Physics_Update(_delta:float):
	pass
