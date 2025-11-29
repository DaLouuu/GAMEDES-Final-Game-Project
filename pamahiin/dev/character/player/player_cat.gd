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
@export var footstep_sfx_map: Dictionary[String, Resource] = {
	"ground_stone": preload("uid://ddty6kh3k1x7p"),
	"salt": preload("uid://qnqi6x0wy5g7"),
	"wood_plank": preload("uid://4xdwy8c4atu4"),
	"carpet": preload("uid://bryk4kumpuid"),
	"grass": preload("uid://dqwal04bj3dqk"),
	"stone": preload("uid://deyrlfjtlv8c3"),
	"tile": preload("uid://cccmwejegywa6")
	"bone": preload("uid://cfueffcslv628")
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
@onready var audioPlayer : AudioStreamPlayer2D = $"AudioStreamPlayer2D-FootSound"
@onready var uiLayer:CanvasLayer = $CanvasLayer
@onready var GrabSound_asp:AudioStreamPlayer2D = $"AnimationPlayer-GrabSound"
func changeFootstepSound():
	if not Global.game_controller:
		return
		
	#var location = Global.game_controller.locationType
	#var audio_path = "res://art/Audio Assets/"
	#var isCave: bool = false
	## Map location types to footstep sounds
	#match location:
		#EnumsRef.LocationType.GRAVEYARD, \
		#EnumsRef.LocationType.GARDEN, \
		#EnumsRef.LocationType.WORLD:
			## Grass footsteps
			#footsteps_Sound = load(audio_path + "5 - Stomping on Grass.wav")
			#
		#EnumsRef.LocationType.MOTEL, \
		#EnumsRef.LocationType.HOME:
			## Tile footsteps
			#footsteps_Sound = load(audio_path + "6 - Stomping on Tile.wav")
			#
		#EnumsRef.LocationType.CHAPEL:
						## Stone footsteps
			#footsteps_Sound = load(audio_path + "7 - Stomping on Stone.wav")
		#EnumsRef.LocationType.CAVE:
			#audioPlayer.stream =null
			#isCave = true
	#
	## Update the audio player with new footstep sound
	#if footsteps_Sound and audioPlayer and not isCave:
		#audioPlayer.stream = footsteps_Sound
		#print("🔊 Footstep sound changed to: ", location)
		
	
	
func _ready():
	for ctrl in $CanvasLayer.get_children():
		if ctrl is Control:
			ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	var is_sprinting = Input.is_action_pressed("sprint")
	
	if is_sprinting:
		current_speed *= sprint_multiplier
		# Speed up animation to match sprint speed
		animation_tree.set("parameters/TimeScale/scale", sprint_multiplier)
		 #Also speed up footstep sounds
		audioPlayer.pitch_scale = sprint_multiplier
		audioPlayer.volume_db = 5.0
		
	else:
		# Normal animation speed
		animation_tree.set("parameters/TimeScale/scale", 1.0)

		audioPlayer.pitch_scale = 1.0
		audioPlayer.volume_db = 0

		
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
func ReceiveSanityDamage(dmg: float, effect_name : EnumsRef.HitEffectType):	
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
func collect(item : InvItem):
	if item.name == "Lantern":
		turnOnLight()
	GrabSound_asp.play(0.10)
	inventory.obtain(item)


## CUTSCENE UTIL
func lerp_towards(target: Marker2D, duration: float) -> void:
	is_cutscene_controlled = true
	
	var dir := (target.global_position - global_position).normalized()
	update_animation_parameters(dir)
	pick_new_state()
	
	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", target.global_position, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished
	
	velocity = Vector2.ZERO
	update_animation_parameters(Vector2.ZERO)
	pick_new_state()
	
	is_cutscene_controlled = false

func move_towards(target: DirectionMarker) -> void:
	is_cutscene_controlled = true
	
	var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
	navigation_agent_2d.target_position = target.global_position
	
	await get_tree().physics_frame
	
	while not navigation_agent_2d.is_navigation_finished():
		var direction: Vector2 = navigation_agent_2d.get_next_path_position() - global_position
		direction = direction.normalized()
	
		velocity = velocity.lerp(direction * move_speed, 5 * get_process_delta_time())
		move_and_slide()
			
		update_animation_parameters(direction)
		pick_new_state()
	
		await get_tree().physics_frame
	
	velocity = Vector2.ZERO
	update_animation_parameters(target.direction)
	pick_new_state()
	
	is_cutscene_controlled = false


## FOOTSTEP SFX
func _init_footstep_sfx_playing_dict() -> void:
	for tile_type in footstep_sfx_map:
		_is_footstep_sfx_playing[tile_type] = false
func attempt_play_footsteps() -> void:
	var tile_data: Array[TileData] = []
	
	for child in tile_maps.get_children():
		var tilemap := child as TileMapLayer
		
		var tile_position := tilemap.local_to_map(tilemap.to_local(global_position))
		var data := tilemap.get_cell_tile_data(tile_position)
		
		if data:
			tile_data.push_back(data)
	
	for tile_datum in tile_data:
		var tile_type = tile_datum.get_custom_data('footstep_sfx')
		
		if footstep_sfx_map.has(tile_type) and not _is_footstep_sfx_playing[tile_type]:
			var audio_player := AudioStreamPlayer2D.new()
			audio_player.stream = footstep_sfx_map[tile_type]
			audio_player.global_position = global_position
			
			get_tree().root.add_child(audio_player)
			
			_is_footstep_sfx_playing[tile_type] = true
			
			audio_player.finished.connect(func():
				audio_player.queue_free()
				_is_footstep_sfx_playing[tile_type] = false
			)
			
			audio_player.play()
