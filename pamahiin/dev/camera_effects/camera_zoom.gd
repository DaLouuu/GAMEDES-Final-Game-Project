class_name CameraZoom
extends CameraEffect

@export var target_zoom: float = 1.4     # Zoom IN amount
@export var speed_in: float = 10.0         # How fast we go in
@export var speed_out: float = 12.0        # How fast we relax outward

var original_zoom: Vector2
var pulsing_out := false                  # We begin zooming inward first

func start(original_zoom_value: Vector2):
	original_zoom = original_zoom_value

func apply(camera: Camera2D, delta: float):
	var zoom_vec = Vector2(target_zoom, target_zoom)

	if not pulsing_out:
		# Phase 1: Zoom in
		camera.zoom = camera.zoom.lerp(zoom_vec, delta * speed_in)

		if camera.zoom.distance_to(zoom_vec) < 0.01:
			pulsing_out = true

	else:
		# Phase 2: Zoom back out
		camera.zoom = camera.zoom.lerp(original_zoom, delta * speed_out)

		if camera.zoom.distance_to(original_zoom) < 0.01:
			# Finished pulse
			camera.zoom = original_zoom
			is_finished = true
