extends Node2D

@onready var default_coords: Vector2 = $"Marker2D-SpawnP".position
@onready var itemKey = $ItemTemplate

var locationType : EnumsRef.LocationType = EnumsRef.LocationType.HOME

func getLocationType()->EnumsRef.LocationType:
	return locationType
func _ready():
	$WhiteLady.start_funcs()
	if $ItemTemplate.has_signal("item_collected"):
		$ItemTemplate.item_collected.connect(jumpscare_node)
	else:
		print("❌ ItemTemplate does NOT have signal item_collected")
	
func jumpscare_node(item:InvItem):
	print("boo")
	
	var rect := $CanvasLayer/TextureRect
	rect.visible = true
	rect.modulate.a = 1.0
	rect.scale = Vector2.ONE

	# Create tween
	var t := create_tween()
	t.set_parallel(true)  # run effects simultaneously
	$AudioStreamPlayer2D.play(15.33)

	# Rapid scale jitter (shake effect)
	t.tween_property(rect, "scale", Vector2(1.1, 0.9), 0.05).as_relative()
	t.tween_property(rect, "scale", Vector2(0.9, 1.1), 0.05).as_relative()
	t.tween_property(rect, "scale", Vector2(1.05, 1.05), 0.05).as_relative()
	t.tween_property(rect, "scale", Vector2(0.95, 0.95), 0.05).as_relative()

	# Slow zoom-in over 1 second
	t.tween_property(rect, "scale", Vector2(1.5, 1.5), 1.0)

	# Hide after 1 second
	await get_tree().create_timer(1.0).timeout
	rect.visible = false



	rect.queue_free()
func _on_area_2d_back_to_room_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_check_from("res://map_phase/houses/house2_room.tscn")
func _on_Timer_timeout():
	$AudioStreamPlayer2D.stop()
