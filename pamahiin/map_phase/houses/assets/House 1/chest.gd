extends StaticBody2D


signal chest_opened(item:InvItem)
var is_player_in_range = false
var is_opened_chest = false


func _process(_delta: float) -> void:
	if is_player_in_range and Input.is_action_just_pressed("interact") and GameState.HOUSE_has_gotten_house_key:
		if not is_opened_chest:
			$AnimationPlayer.play("chest_open")
			is_opened_chest = true

		await get_tree().physics_frame
		chest_opened.emit(load("res://dev/resource_scripts/inventory/items/key.tres"))
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/player_inspect_chest.dialogue"))
	elif is_player_in_range and Input.is_action_just_pressed("interact"):
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/chest_locked.dialogue"))
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var pl = body as Player
		$TextureRect.visible = true
		is_player_in_range = true
		chest_opened.connect(pl.delete)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_in_range = false
		$TextureRect.visible = false
		
