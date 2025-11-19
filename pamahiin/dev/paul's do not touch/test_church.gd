extends Node2D


@onready var spawnPoint : Marker2D = $"Marker2D-SpawnP"





# Exit to tp onto next area
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#Global.game_controller.change_2d_scene("res://dev/paul's do not touch/test2scene.tscn")
		enemy.stop_funcs()
		Global.game_controller.change_2d_scene("res://map_phase/chapel/chapel.tscn")
		
