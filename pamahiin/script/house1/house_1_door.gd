extends Sprite2D


func _ready():
	pass

func play_open():
	$AnimationPlayer.play("open_door")
func play_close():
	$AnimationPlayer.play("close_door")
