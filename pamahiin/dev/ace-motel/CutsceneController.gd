extends Node2D

@onready var black_screen = $CanvasLayer/BlackScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/StartDelay.timeout.connect(_on_start_delay_timeout)
	

func _on_start_delay_timeout():
	var coffin_texture = load("res://art/Sprout Lands - Sprites - Basic pack/Objects/Chest.png")
	var coffin = Sprite2D.new()
	coffin.texture = coffin_texture
	$CanvasLayer.add_child(coffin)
	
	coffin.scale = Vector2(2,2)
	
	coffin.position = get_viewport_rect().size / 2
	
	coffin.modulate.a = 0.0
	
	var tween = create_tween()
	
	tween.tween_property(coffin, "modulate:a", 1.0, 2.0)
	
	tween.tween_property(black_screen.material, "shader_parameter/radius", 1.5, 3.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
