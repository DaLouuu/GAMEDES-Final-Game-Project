extends Node2D

@onready var black_screen = $CanvasLayer/BlackScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PlayerCat.is_cutscene_controlled = true
	$Camera2D.make_current()
	$AnimationPlayer.play("playground")
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	#DialogueManager.show_dialogue_balloon(_DIALOGUE_CHURCH)
	#await DialogueManager.dialogue_ended
	
# use only if no dialogue after playing animation
func _on_animation_finished(anim_name: String):
	if anim_name == "playground":
		$PlayerCat.is_cutscene_controlled = false
		$PlayerCat/Camera2D.make_current()
	

func _on_start_delay_timeout():
	var coffin_texture = load("res://map_phase/motel/church_cutscene/coffin.png")
	var coffin = Sprite2D.new()
	coffin.texture = coffin_texture
	$CanvasLayer.add_child(coffin)
	
	coffin.scale = Vector2(0.2,0.2)
	
	coffin.position = get_viewport_rect().size / 2
	
	coffin.modulate.a = 0.0
	
	var tween = create_tween()

	tween.tween_property(coffin, "modulate:a", 1.0, 2.0)
	
	tween.tween_property(black_screen.material, "shader_parameter/radius", 1.5, 5.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
