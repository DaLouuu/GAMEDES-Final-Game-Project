extends StaticBody2D
signal collected_light
var is_player_in_area = false
var player = null
@export var item:InvItem
@export var pickupable = true


func _ready():
	pass
	
func _process(_delta):
	if is_player_in_area and Input.is_action_just_pressed("interact"):
		if pickupable:
			player.collect(item)
			collected_light.emit()
			GameState.PROLOGUE_has_gotten_lamp = true
			# delay after collecting item
			await get_tree().create_timer(0.1).timeout
			self.queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		if pickupable:
			$Label.visible = true
		is_player_in_area = true
		player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		$Label.visible = false
		is_player_in_area = false
		player = null
