class_name InteractionComponentUI
extends Control

@export var interaction_component: Node
@export var interaction_texture_node: TextureRect
@export var interaction_text_node: Label
@export var interaction_default_texture: Texture2D
@export var interaction_default_text: String = "Interact"

var fixed_position: Vector2

func _ready() -> void:
	if interaction_component:
		interaction_component.connect(
			"on_interactable_changed",  # <-- match the detector's signal
			Callable(self, "interactable_target_changed")
		)
	hide()

func _process(delta: float) -> void:
	global_position = fixed_position

func interactable_target_changed(new_interactable: Node) -> void:
	if new_interactable == null:
		hide()
		return
	print("UI showing")
	var interaction_texture: Texture2D = interaction_default_texture
	var interaction_text: String = interaction_default_text

	if new_interactable.has_method("interaction_get_texture"):
		interaction_texture = new_interactable.interaction_get_texture()
	if new_interactable.has_method("interaction_get_text"):
		interaction_text = new_interactable.interaction_get_text()

	if interaction_texture_node:
		interaction_texture_node.texture = interaction_texture
	if interaction_text_node:
		interaction_text_node.text = interaction_text

	if new_interactable is Node2D:
		fixed_position = Vector2(new_interactable.global_position.x, new_interactable.global_position.y - 50)
		global_position = fixed_position

	show()
