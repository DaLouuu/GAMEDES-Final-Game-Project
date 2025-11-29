class_name DefaultNPC
extends CharacterBody2D


@export var move_speed : float = 20
@export var idle_time : float = 2.0
@export var walk_time : float = 5.0


@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var timer = $Timer

var move_direction : Vector2 = Vector2.ZERO
var current_state = EnumsRef.NPCState.IDLE
var is_player_in_range = false

func _ready():
	select_new_direction()
	pick_new_state()
	
func _process(_delta: float) -> void:
	if is_player_in_range and Input.is_action_just_pressed("interact"):
		
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/house_dialogues/little_girl.dialogue"))
			
func _physics_process(_delta):
	if current_state == EnumsRef.NPCState.IDLE:
		return
	
	velocity = move_direction * move_speed
	move_and_slide()


func select_new_direction():
	move_direction = Vector2(
		randi_range(-1,1), randi_range(-1,1)
	)
	if move_direction.x == 0 and move_direction.y==0:
		var num = randi_range(0,1)
		match num:
			0:
				move_direction.x = 0 if move_direction.x else 1
			1:
				move_direction.y = 0 if move_direction.y else 1
				
	animation_tree.set("parameters/Walk/blend_position", move_direction)
func pick_new_state():
	if(current_state == EnumsRef.NPCState.IDLE):
		state_machine.travel("Walk")
		current_state = EnumsRef.NPCState.MOVE
		select_new_direction()
		timer.start(walk_time)
	elif(current_state == EnumsRef.NPCState.MOVE):
		state_machine.travel("Idle")

		current_state = EnumsRef.NPCState.IDLE
		timer.start(idle_time)
		
		
		
	


func _on_timer_timeout() -> void:
	pick_new_state()


func _on_area_2d_body_entered(body: Node2D) -> void:
	is_player_in_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	is_player_in_range = false
