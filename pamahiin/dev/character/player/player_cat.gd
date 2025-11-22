class_name Player


extends CharacterBody2D


signal sanity_changed(new_value: float)
signal sanity_damaged



@export var move_speed : float =  100
@export var sprint_multiplier : float = 1.8
@export	var starting_direction : Vector2 = Vector2(0, 1)
@export var sanity : float = 100.0
@export var invul_duration : float = 5.0
@export var inventory: Inventory
@export var has_light : bool = false

@export var footstep_sfx_map: Dictionary[String, Resource] = {
	"ground_stone": preload("uid://ddty6kh3k1x7p"),
	"salt": preload("uid://qnqi6x0wy5g7")
}
@export var tile_maps: Node

var is_cutscene_controlled := false
var is_invulnerable: bool = false
var max_sanity : float = 100.0

var _is_footstep_sfx_playing: Dictionary[String, bool] = {}

# onready get animation_tree under this node
@onready var animation_tree = $AnimationTree 
@onready var state_machine= animation_tree.get("parameters/playback")
@onready var hit_effect_manager = $HitEffectManager
@onready var invul_timer = $InvulTimer
@onready var remote_transform_2d = $RemoteTransform2D
@onready var camera : Camera2D = $Camera2D


func _ready():
	_init_footstep_sfx_playing_dict()
	
	update_animation_parameters(starting_direction)
	remote_transform_2d.remote_path = camera.get_path()
	
	# For debugging purposes lets you know object ids that pass through certain events
	var obj = instance_from_id(41003517335)
	if obj:
		print(obj.name)
		print(obj.get_path())
		

# Anything moving and colliding is always under the collision
func _physics_process(delta):
	if is_cutscene_controlled:
		return
	
	# Smart logic cancelling inputs of both directional keys
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up") 
	)
	update_animation_parameters(input_direction)
	
	# Sprinting multiplier
	var current_speed = move_speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier
	
	velocity = input_direction * current_speed
	
	# move_and_slide() is very static when hitting object, move_and_collied accounts for object hit	
	var collision = move_and_slide()

	#if collision and collision.get_collider().is_in_group("door"):
		#collision.get_collider().play_open()   # call method on door
	pick_new_state()



# Movement Animation Logic
func update_animation_parameters(move_input : Vector2):
	
	# When the movement input 
	if(move_input != Vector2.ZERO):
		animation_tree.set("parameters/Walk/blend_position", move_input)
		animation_tree.set("parameters/Idle/blend_position", move_input)

# Animation Selection logic
func pick_new_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

# Sanity Logic
func ReceiveSanityDamage(dmg: float, effect_name : String):	
	if is_invulnerable:
		return
	

	# Hit effect manager should implement how sanity would be decreased	
	hit_effect_manager.apply_hit_effect(effect_name, dmg, self)	
	
	# Clamping restricts between 0 and max sanity value
	#sanity = clamp(sanity - dmg, 0, max_sanity)
	#
	#
	#print("💢 Player sanity now:", sanity)
	#sanity_changed.emit(sanity)
	#sanity_damaged.emit()
	#is_invulnerable = true
	#invul_timer.start()

# ✅ When invulnerability period ends
func _on_invul_timer_timeout():
	is_invulnerable = false
	print("🔓 Player is now vulnerable again.")
func turnOnLight():
	$PointLight2D.enabled = true
	
# Player adds item to his inventory	
func collect(item : InvItem, count: int  = 1):
	if item.name == "Lantern":
		turnOnLight()
	inventory.obtain(item, count)
	
