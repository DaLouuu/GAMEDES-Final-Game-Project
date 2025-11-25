extends Area2D

@onready var blocker: StaticBody2D = $StaticBody2D
@onready var blocker_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var prompt: Label = $PromptLabel

var _player_inside := false
var _is_open := false

func _ready() -> void:
	prompt.visible = false
	prompt.text = "[E] Open gate"

func _process(_delta: float) -> void:
	if _player_inside and Input.is_action_just_pressed("interact"):
		_toggle_gate()

func _toggle_gate() -> void:
	_is_open = !_is_open
	blocker_shape.disabled = _is_open      # when open, no collision
	prompt.visible = false                 # hide prompt after use
	# optional: change sprite frame here to show open/closed gate

func _on_Gate_body_entered(body: Node):
	if body.is_in_group("Player") and not _is_open:
		_player_inside = true
		prompt.visible = true

func _on_Gate_body_exited(body: Node):
	if body.is_in_group("Player"):
		_player_inside = false
		prompt.visible = false
