extends Node2D

@onready var houseDoor : Sprite2D  = $HouseParts/House2Door
func _on_area_2d_sound_trigger_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		houseDoor.open_door()

func _on_area_2d_sound_trigger_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		houseDoor.close_door()
		
func _process(_delta: float) -> void:
	pass
