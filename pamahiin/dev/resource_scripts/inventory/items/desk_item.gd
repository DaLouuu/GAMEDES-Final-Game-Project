extends Node2D

var is_player_in_area = false
var player = null
@export var item:InvItem



func _read():
	pass
	
func _process(_delta):
	if is_player_in_area and Input.is_action_just_pressed("interact"):
		player.collect(item)
		
		# delay after collecting item
		await get_tree().create_timer(0.1).timeout
		self.queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		is_player_in_area = true
		player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		is_player_in_area = false
		player = null
