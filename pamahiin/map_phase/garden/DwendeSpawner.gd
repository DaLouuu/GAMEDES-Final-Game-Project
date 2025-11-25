extends Node2D

@export var duwende_scene: PackedScene
@export var max_active_duwendes: int = 3
@export var spawn_cooldown: float = 1.5

var active_duwendes := []
var can_spawn := true


func spawn(at_position: Vector2):
	if not can_spawn:
		print("DuwendeSpawner: spawn cooldown active.")
		return

	if duwende_scene == null:
		print("DuwendeSpawner: duwende_scene is not set.")
		return

	if active_duwendes.size() >= max_active_duwendes:
		print("DuwendeSpawner: max duwendes reached.")
		return

	var d := duwende_scene.instantiate()
	add_child(d)
	d.global_position = at_position

	# optional: add to group for easy lookup
	d.add_to_group("duwende")

	active_duwendes.append(d)

	# -------------------------------------------------------
	# CORRECT SIGNAL BINDING (expects the duwende node as arg)
	# -------------------------------------------------------
	if d.has_signal("died"):
		# died emits (duwende)
		d.died.connect(_on_duwende_cleanup)
	if d.has_signal("finished_behavior"):
		# finished_behavior emits (duwende)
		d.finished_behavior.connect(_on_duwende_cleanup)

	_start_cooldown()


func _start_cooldown():
	can_spawn = false

	var t := Timer.new()
	t.wait_time = spawn_cooldown
	t.one_shot = true
	add_child(t)

	t.timeout.connect(func():
		can_spawn = true
		# schedule the timer node for free
		if is_instance_valid(t):
			t.queue_free()
	)

	t.start()


func _on_duwende_cleanup(d):
	# safety: ensure valid instance
	if d == null:
		return

	# If the duwende is in active_duwendes, remove it
	if d in active_duwendes:
		active_duwendes.erase(d)

	# Free the duwende node if still valid and not already queued
	if is_instance_valid(d) and not d.is_queued_for_deletion():
		d.queue_free()
