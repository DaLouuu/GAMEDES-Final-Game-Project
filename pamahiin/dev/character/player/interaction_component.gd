extends Area2D

@export var interaction_parent: NodePath
signal on_interactable_changed(new_interactable)

var interaction_target: Node = null

func _process(delta: float) -> void:
	if interaction_target != null and Input.is_action_just_pressed("interact"):
		if interaction_target.has_method("interaction_interact"):
			interaction_target.interaction_interact(self)
		
func _on_InteractionComponent_body_entered(body: Node) -> void:
	var can_interact := false
	
	if body.has_method("interaction_can_interact"):
		can_interact = body.interaction_can_interact(get_node(interaction_parent))
		
	if not can_interact:
		return
	
	interaction_target = body
	emit_signal("on_interactable_changed", body)

func _on_InteractionComponent_body_exited(body: Node) -> void:
	if body == interaction_target:
		interaction_target = null
		emit_signal("on_interactable_changed", null)
