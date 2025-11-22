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
@export var sprintSoundMaxDistance = 350
@export var walkSoundMaxDistance = 200

var footsteps_Sound : AudioStream
var is_invulnerable: bool = false
var max_sanity : float = 100.0
# onready get animation_tree under this node
@onready var animation_tree = $AnimationTree 
@onready var state_machine= animation_tree.get("parameters/playback")
@onready var hit_effect_manager = $HitEffectManager
@onready var invul_timer = $InvulTimer
@onready var remote_transform_2d = $RemoteTransform2D
@onready var camera : Camera2D = $Camera2D
@onready var audioPlayer : AudioStreamPlayer2D = $"AudioStreamPlayer2D-FootSound"

func changeFootstepSound():
	if not Global.game_controller:
		return
		
	var location = Global.game_controller.locationType
	var audio_path = "res://art/Audio Assets/"
	
	# Map location types to footstep sounds
	match location:
		EnumsRef.LocationType.GRAVEYARD, \
		EnumsRef.LocationType.GARDEN, \
		EnumsRef.LocationType.WORLD:
			# Grass footsteps
			footsteps_Sound = load(audio_path + "5 - Stomping on Grass.wav")
			
		EnumsRef.LocationType.MOTEL, \
		EnumsRef.LocationType.HOME:
			# Tile footsteps
			footsteps_Sound = load(audio_path + "6 - Stomping on Tile.wav")
			
		EnumsRef.LocationType.CHAPEL, \
		EnumsRef.LocationType.CAVE:
			# Stone footsteps
			footsteps_Sound = load(audio_path + "7 - Stomping on Stone.wav")
	
	# Update the audio player with new footstep sound
	if footsteps_Sound and audioPlayer:
		audioPlayer.stream = footsteps_Sound
		print("🔊 Footstep sound changed to: ", location)
		
	
	
func _ready():
	update_animation_parameters(starting_direction)
	remote_transform_2d.remote_path = camera.get_path()
	
	# For debugging purposes lets you know object ids that pass through certain events
	var obj = instance_from_id(41003517335)
	if obj:
		print(obj.name)
		print(obj.get_path())
		

# Anything moving and colliding is always under the collision
func _physics_process(delta):
	
	# Smart logic cancelling inputs of both directional keys
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up") 
	)
	update_animation_parameters(input_direction)
	
	# Sprinting multiplier
	var current_speed = move_speed
	var is_sprinting = Input.is_action_pressed("sprint")
	
	if is_sprinting:
		current_speed *= sprint_multiplier
		# Speed up animation to match sprint speed
		animation_tree.set("parameters/TimeScale/scale", sprint_multiplier)
		# Also speed up footstep sounds
		if audioPlayer:
			audioPlayer.pitch_scale = sprint_multiplier
			if Global.game_controller.locationType == EnumsRef.LocationType.WORLD:
				audioPlayer.volume_db = -8.0
			else:
				audioPlayer.volume_db = 10.0
				
			audioPlayer.max_distance = sprintSoundMaxDistance
			
	else:
		# Normal animation speed
		animation_tree.set("parameters/TimeScale/scale", 1.0)
		# Normal footstep pitch
		if audioPlayer:
			
			audioPlayer.pitch_scale = 1.0
			audioPlayer.volume_db = 10.0
			
			audioPlayer.max_distance = walkSoundMaxDistance
		
	velocity = input_direction * current_speed
	
	

	# move_and_slide() is very static when hitting object, move_and_collied accounts for object hit	
	var collision = move_and_collide(velocity * delta)
	
	if collision and collision.get_collider().is_in_group("door"):
		collision.get_collider().play_open()   # call method on door
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
