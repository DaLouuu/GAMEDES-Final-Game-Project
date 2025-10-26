extends Node

@onready var _jumpscare_animation_player: AnimationPlayer = $Jumpscare/JumpscareAnimationPlayer
@onready var _jumpscare_timer: Timer = $JumpscareTimer
@onready var _quick_time_event: QuickTimeEvent = $QuickTimeEvent

@onready var _camera_2d: Camera2D = $Camera2D
@onready var _mirror: AnimatedSprite2D = $MirrorArea/Mirror
@onready var _sari_sari_bg: Sprite2D = $SariSariBg

func _on_mirror_area_mouse_shape_entered(_shape_idx: int) -> void:
	_mirror.play("sparkle")
	_jumpscare_timer.start()

func _on_mirror_area_mouse_exited() -> void:
	_mirror.play("default")
	_jumpscare_timer.stop()

func _on_jumpscare_timer_timeout() -> void:
	_jumpscare_animation_player.play('jumpscare')
	
	_camera_2d.start_shake()
	_sari_sari_bg.start_shake()
	
	_quick_time_event.trigger()

func _on_quick_time_event_finished() -> void:
	pass # Replace with function body.
