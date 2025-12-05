extends Node2D

@export var duwende_scene: PackedScene
@export var max_active_duwendes: int = 3
@export var spawn_cooldown: float = 1.5

var active_duwendes: Array = []
var can_spawn: bool = true


func spawn(at_position: Vector2) -> void:
	if not can_spawn:
		return

	if duwende_scene == null:
		print("DuwendeSpawner Error: duwende_scene is not set in Inspector.")
		return

	if active_duwendes.size() >= max_active_duwendes:
		# Optional: print("Max dwendes reached.")
		return

	var d := duwende_scene.instantiate()
	
	# Add to the current scene root so they aren't affected if the Spawner moves/scales
	# If you prefer them to be children of the spawner, use add_child(d)
	get_tree().current_scene.add_child(d)
	
	d.global_position = at_position
	d.add_to_group("duwende")
	active_duwendes.append(d)

	# --- CONNECTION UPDATE ---
	# Only listen for DEATH. Do not listen for "finished_behavior".
	if d.has_signal("died"):
		d.died.connect(_on_duwende_cleanup)

	# We REMOVED the "finished_behavior" connection here.
	# This guarantees the spawner will NEVER delete a living Dwende.

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
	
	# Only free if it's valid and not already being freed
	if is_instance_valid(d) and not d.is_queued_for_deletion():
		d.queue_free()
