extends Area2D

@export_multiline var sign_text: String = ""

@onready var label: Label = $Label
@onready var prompt: Label = $PromptLabel

var _player_inside := false

func _ready() -> void:
	label.visible = false
	label.text = sign_text
	prompt.visible = false
	prompt.text = "[E] Interact"

func _process(_delta: float) -> void:
	if _player_inside and Input.is_action_just_pressed("interact"):
		label.visible = !label.visible
		prompt.visible = not label.visible

func _on_Sign_body_entered(body: Node) -> void:
	print("body_entered: ", body.name)
	if body.is_in_group("Player"):
		_player_inside = true
		if not label.visible:
			prompt.visible = true
		print("Prompt visible: ", prompt.visible, " at ", prompt.position)

func _on_Sign_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		_player_inside = false
		prompt.visible = false
		label.visible = false
