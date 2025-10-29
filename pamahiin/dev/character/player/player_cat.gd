class_name Player


extends CharacterBody2D

signal sanity_changed(new_value: float)
@export var move_speed : float =  100
@export var sprint_multiplier : float = 1.8
@export	var starting_direction : Vector2 = Vector2(0, 1)
@export var sanity : float = 100.0
@export var invul_duration : float = 5.0

var is_invulnerable: bool = false
var max_sanity : float = 100.0
# onready get animation_tree under this node
@onready var animation_tree = $AnimationTree 
@onready var state_machine= animation_tree.get("parameters/playback")
@onready var hit_effect_manager = $HitEffectManager
@onready var invul_timer = $InvulTimer
@onready var remote_transform_2d = $RemoteTransform2D
@onready var camera : Camera2D = $Camera2D


func _ready():
	update_animation_parameters(starting_direction)
	remote_transform_2d.remote_path = camera.get_path()
	invul_timer.wait_time = invul_duration
	invul_timer.one_shot = true
	invul_timer.timeout.connect(_on_invul_timer_timeout)

# Anything moving and colliding is always under the collision
func _physics_process(delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up") 
	)
	update_animation_parameters(input_direction)
	var current_speed = move_speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier
	
	velocity = input_direction * current_speed
	
	#move_and_slide()
	var collision = move_and_collide(velocity * delta)
	if collision and collision.get_collider().is_in_group("door"):
		collision.get_collider().play_open()   # call method on door
	pick_new_state()



	# Movement Animation Logic
func update_animation_parameters(move_input : Vector2):
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)
		
func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

# Sanity Logic
func ReceiveSanityDamage(dmg: float, effect_name : String):
	#if is_invulnerable:
		#print("🛡️ Player is invulnerable — no damage taken.")
		#return
#
	#sanity = clamp(sanity - dmg, 0, max_sanity)
	#print("💢 Player sanity now:", sanity)
	#emit_signal("sanity_changed", sanity)
	#is_invulnerable = true
	#invul_timer.start()
#
	
	if is_invulnerable:
		return

	sanity = clamp(sanity - dmg, 0, max_sanity)
	print("💢 Player sanity now:", sanity)
	emit_signal("sanity_changed", sanity)
	CameraShake()
	hit_effect_manager.apply_hit_effect(effect_name, dmg)
	
	is_invulnerable = true
	invul_timer.start()

# ✅ When invulnerability period ends
func _on_invul_timer_timeout():
	is_invulnerable = false
	print("🔓 Player is now vulnerable again.")


func CameraShake():
	if camera and camera.has_method("start_shake"):
		camera.start_shake(10.0)
