class_name GameController
extends Node

@export var gui: Control
@export var world_2d: Node2D

var curr_2d_scene: Node = null
var curr_gui_scene: Node = null

func _ready() -> void:
	Global.game_controller = self


func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	# Placeholder: implement GUI scene swapping later
	return


func change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if curr_2d_scene:
		if delete:
			curr_2d_scene.queue_free()
		elif keep_running:
			curr_2d_scene.visible = false
		else:
			gui.remove_child(curr_2d_scene)

	var new_scene_instance = load(new_scene).instantiate()
	world_2d.add_child(new_scene_instance)
	curr_2d_scene = new_scene_instance
