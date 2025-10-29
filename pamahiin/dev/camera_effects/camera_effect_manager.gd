class_name CameraEffectManager
extends Camera2D

var effects: Array[CameraEffect] = []
@onready var camera: Camera2D = self
@onready var player: CharacterBody2D = $".."

var original_offset: Vector2
var original_zoom: Vector2
var blur_material



func _ready():
	original_offset = camera.offset
	original_zoom = camera.zoom
	player.sanity_damaged.connect(start_shake)
	var sprite = get_node_or_null("../CanvasLayer/BlurSprite")
	if sprite:
		print("Sprite ready for blur")
		blur_material = sprite.material
		
func _process(delta):
	if effects.is_empty():
		return
	for effect in effects:
		effect.apply(camera, delta)
	
	effects = effects.filter(func(e): return not e.is_finished)
func add_effect(effect:CameraEffect):
	effects.append(effect)
	
	if effect is CameraShake:
		effect.start(original_offset)
	elif effect is CameraZoom:
		effect.start(original_zoom)

		
func start_shake(strength: float = 10):	
	add_effect(CameraShake.new())
	add_effect(CameraZoom.new())
	
	
