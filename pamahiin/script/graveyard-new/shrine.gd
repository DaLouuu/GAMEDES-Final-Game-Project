extends Area2D 

@export_multiline var inscription_text: String = ""

var dialogue_ui: Node = null
var _player_inside := false

func _ready() -> void:
	var candidates = get_tree().get_nodes_in_group("dialogue_ui")
	if candidates.size() > 0:
		dialogue_ui = candidates[0]

func _process(_delta: float) -> void:
	if _player_inside and Input.is_action_just_pressed("interact") and dialogue_ui:
		if dialogue_ui.is_showing():
			dialogue_ui.hide_text()
		else:
			dialogue_ui.show_text(inscription_text)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		_player_inside = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		_player_inside = false
		if dialogue_ui and dialogue_ui.is_showing():
			dialogue_ui.hide_text()
