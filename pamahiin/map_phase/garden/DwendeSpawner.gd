extends Node2D

@export var duwende_scene: PackedScene
@export var max_active_duwendes: int = 3
@export var spawn_cooldown: float = 1.5

var active_duwendes: Array = []
var can_spawn: bool = true


func spawn(at_position: Vector2) -> void:
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

	# add to group
	d.add_to_group("duwende")
	active_duwendes.append(d)

	# connect cleanup signals if available
	if d.has_signal("died"):
		d.died.connect(_on_duwende_cleanup)
	if d.has_signal("finished_behavior"):
		d.finished_behavior.connect(_on_duwende_cleanup)

	_start_cooldown()


func _start_cooldown() -> void:
	can_spawn = false
	var t := Timer.new()
	t.wait_time = spawn_cooldown
	t.one_shot = true
	add_child(t)
	t.timeout.connect(func():
		can_spawn = true
		if is_instance_valid(t):
			t.queue_free()
	)
	t.start()


func _on_duwende_cleanup(d) -> void:
	if d == null:
		return
	if d in active_duwendes:
		active_duwendes.erase(d)
	if is_instance_valid(d) and not d.is_queued_for_deletion():
		d.queue_free()
