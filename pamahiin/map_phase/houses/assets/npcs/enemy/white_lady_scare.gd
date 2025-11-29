extends CanvasLayer

@onready var tex_rect: TextureRect = $TextureRect
@onready var timer: Timer = $Timer

func show_popup(texture: Texture2D, duration := 0.5):
	tex_rect.texture = texture
	tex_rect.visible = true
	timer.start(duration)
	$AudioStreamPlayer2D.play(15.33)
func _on_Timer_timeout():
	tex_rect.visible = false
	$AudioStreamPlayer2D.stop()
	
