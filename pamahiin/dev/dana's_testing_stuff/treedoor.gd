extends Node2D

@export var marking_id: String = ""
@export var is_correct_tree: bool = false

signal correct_knock(tree)
signal wrong_knock(tree)

var player_in_range := false

@onready var interact_area = $Area2D
@onready var anim = $AnimationPlayer
@onready var knock_sfx = $AudioStreamPlayer
@onready var prompt = $InteractionPrompt   # <--- NEW


func _ready():
	add_to_group("treedoor")

	interact_area.body_entered.connect(_on_entered)
	interact_area.body_exited.connect(_on_exited)

	prompt.visible = false   # hide at start


func _on_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		prompt.visible = true   # SHOW TEXT


func _on_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		prompt.visible = false  # HIDE TEXT


func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		_knock()


func _knock():
	if knock_sfx:
		knock_sfx.play()

	var cicadas_on: bool = false
	if Global.game_controller and Global.game_controller.garden_state:
		cicadas_on = Global.game_controller.garden_state.cicadas_active

	# CORRECT
	if is_correct_tree and cicadas_on:
		anim.play("correct_flash")
		anim.play("shake")
		emit_signal("correct_knock", self)
		return

	# WRONG
	anim.play("wrong_flash")
	anim.play("shake")
	emit_signal("wrong_knock", self)
