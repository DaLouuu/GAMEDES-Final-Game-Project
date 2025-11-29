@tool
class_name DirectionMarker
extends Marker2D

const ARROW_LENGTH := 15.0
const ARROW_HEAD_SIZE := 5.0
const ARROW_HEAD_ANGLE := 0.5
const ARROW_WIDTH := 1.0
const ARROW_COLOR := Color(1.0, 0.0, 0.51, 0.5)

@export_range(0, 360) var angle := 0.0:
	set(value):
		angle = value
		queue_redraw()

var direction: Vector2:
	get:
		return Vector2.from_angle(deg_to_rad(angle))

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	var target := direction * ARROW_LENGTH
	draw_line(Vector2.ZERO, target, ARROW_COLOR, ARROW_WIDTH)

	var angle_rad := deg_to_rad(angle)
	var head_angle_1 := angle_rad + PI + ARROW_HEAD_ANGLE
	var head_angle_2 := angle_rad + PI - ARROW_HEAD_ANGLE

	draw_line(target, target + Vector2.from_angle(head_angle_1) * ARROW_HEAD_SIZE, ARROW_COLOR, ARROW_WIDTH)
	draw_line(target, target + Vector2.from_angle(head_angle_2) * ARROW_HEAD_SIZE, ARROW_COLOR, ARROW_WIDTH)
