extends Sprite2D


func open_door():
	$AnimationPlayer.play("open_door")
	
func close_door():
	$AnimationPlayer.play("close_door")
