extends StaticBody2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready():
	anim_player.play("slowly_fading fire")
	
	
