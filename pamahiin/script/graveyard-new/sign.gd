#extends Area2D
#
#@export_multiline var sign_text: String = ""
#@export var dialogue_ui_path: NodePath
#
## @onready var label: Label = $Label
#@onready var prompt: Label = $PromptLabel 
## @onready var dialogue_ui := get_tree().current_scene.get_node("DialogueUI")
##@onready var dialogue_ui := get_tree().current_scene.get_node_or_null(dialogue_ui_path)
#@onready var dialogue_ui := get_node_or_null(dialogue_ui_path)
#
#var _player_inside := false
#
#func _ready() -> void:
	#prompt.visible = false
	#prompt.text = "[E] Interact"
#
#
#func _process(_delta: float) -> void:
	#if _player_inside and Input.is_action_just_pressed("interact"):
		#if dialogue_ui == null: 
			#print("Sign: dialogueUI is null, cannot show text") 
			#return
		#
		#if dialogue_ui.is_showing():
			#dialogue_ui.hide_text()
			#prompt.visible = true
		#else:
			#dialogue_ui.show_text(sign_text)
			#prompt.visible = false
#
#
#func _on_Sign_body_entered(body: Node) -> void:
	#print("body_entered: ", body.name)
	#if not body.is_in_group("Player"):
		#return
#
	#_player_inside = true
	#prompt.visible = true
#
#
#func _on_Sign_body_exited(body: Node) -> void:
	#if not body.is_in_group("Player"):
		#return
#
	#_player_inside = false
	#prompt.visible = false
#
	#if dialogue_ui != null and dialogue_ui.is_showing():
		#dialogue_ui.hide_text()

extends Area2D

@export_multiline var sign_text: String = ""

@onready var prompt: Label = $PromptLabel
var dialogue_ui: Node = null

var _player_inside := false

func _ready() -> void:
	prompt.visible = false
	prompt.text = "[E] Interact"

	# Find DialogueUI once via group
	var candidates = get_tree().get_nodes_in_group("dialogue_ui")
	if candidates.size() > 0:
		dialogue_ui = candidates[0]
		print(name, ": Found DialogueUI -> ", dialogue_ui.name)
	else:
		dialogue_ui = null
		print(name, ": No DialogueUI found in group 'dialogue_ui'")

func _process(_delta: float) -> void:
	if _player_inside and Input.is_action_just_pressed("interact"):
		if dialogue_ui == null:
			print(name, ": dialogue_ui is NULL, cannot show text")
			return

		if dialogue_ui.is_showing():
			dialogue_ui.hide_text()
			prompt.visible = true
		else:
			dialogue_ui.show_text(sign_text)
			prompt.visible = false

func _on_Sign_body_entered(body: Node) -> void:
	print(name, " body_entered: ", body.name)
	if not body.is_in_group("Player"):
		return

	_player_inside = true
	prompt.visible = true

func _on_Sign_body_exited(body: Node) -> void:
	if not body.is_in_group("Player"):
		return

	_player_inside = false
	prompt.visible = false

	if dialogue_ui != null and dialogue_ui.is_showing():
		dialogue_ui.hide_text()
