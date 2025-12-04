class_name Player


extends CharacterBody2D

signal artifact_collect(item:InvItem)
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
	"cave_stone": preload("uid://ddty6kh3k1x7p"),
	"salt": preload("uid://qnqi6x0wy5g7"),
	"wood": preload("uid://4xdwy8c4atu4"),
	"carpet": preload("uid://bryk4kumpuid"),
	"grass": preload("uid://dqwal04bj3dqk"),
	#"stone": preload("uid://deyrlfjtlv8c3"),
	"tile": preload("uid://cccmwejegywa6"),
	"bone": preload("uid://cfueffcslv628"),
	"soil": preload("uid://o5nf5hj0jvn6")
}
@export var tile_maps: Node

var is_cutscene_controlled := false
var cutscene_animation_state := "Idle"
var cutscene_animation_direction := Vector2.DOWN
var is_motel_introduction := false

var is_invulnerable: bool = false
var max_sanity : float = 100.0

var _is_footstep_sfx_playing: Dictionary[String, bool] = {}

# onready get animation_tree under this node
@onready var animation_tree = $AnimationTree 
@onready var animation_player = $AnimationPlayer
@onready var state_machine= animation_tree.get("parameters/playback")
@onready var hit_effect_manager = $HitEffectManager
@onready var invul_timer = $InvulTimer
@onready var remote_transform_2d = $RemoteTransform2D
@onready var camera : Camera2D = $Camera2D
@onready var audioPlayer : AudioStreamPlayer2D = $"AudioStreamPlayer2D-FootSound"
@onready var uiLayer:CanvasLayer = $CanvasLayer
@onready var GrabSound_asp:AudioStreamPlayer2D = $"AnimationPlayer-GrabSound"
@onready var audioPlayerNearDeath = $"AudioStreamPlayer2D-Heartbeat"

func changeFootstepSound():
	if not Global.game_controller:
		return
		
	#var location = Global.game_controller.locationType
	#var audio_path = "res://art/Audio Assets/"
	#var isCave: bool = false

func trigger_cat_ready():
	$Camera2D.make_current()
	sanity_changed.connect(check_health_changes)
	$CanvasLayer/ArtifactProgress.text = "Artifact: " + str(Global.artifactCount) +"/4"
	$CanvasLayer.visible = true
	for ctrl in $CanvasLayer.get_children():
		if ctrl is Control:
			ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_init_footstep_sfx_playing_dict()
	$Sprite2D.texture = load("res://dev/character/player/Character_Spritesheet_Walking.png")
	update_animation_parameters(starting_direction)
	remote_transform_2d.remote_path = camera.get_path()	
	
func _ready():
	$CanvasLayer.visible = false	
	pass
	
	# For debugging purposes lets you know object ids that pass through certain events
	#var obj = instance_from_id(41003517335)
	#if obj:
		#print(obj.name)
		#print(obj.get_path())
		
func setCutsceneAnimationBehavior(state : String, direction : Vector2):
	cutscene_animation_state = state
	cutscene_animation_direction = direction

# Anything moving and colliding is always under the collision
func _physics_process(_delta):
	
	if sanity <= 0:
		return
	if is_cutscene_controlled:
		if is_motel_introduction:
			update_animation_parameters(cutscene_animation_direction)
			state_machine.travel(cutscene_animation_state)
		return
	
	# Smart logic cancelling inputs of both directional keys
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up") 
	)
	input_direction = input_direction.normalized()
	update_animation_parameters(input_direction)
	
	# Sprinting multiplier
	var current_speed = move_speed
	var is_sprinting = Input.is_action_pressed("sprint")
	$FootStepManager.mode = $FootStepManager.Mode.LAYERED

	if is_sprinting:
		current_speed *= sprint_multiplier
		$FootStepManager.base_player.pitch_scale =  sprint_multiplier
		$FootStepManager.base_player.volume_db =  5.0
		# Speed up animation to match sprint speed
		animation_tree.set("parameters/TimeScale/scale", sprint_multiplier)
		 ##Also speed up footstep sounds
		#audioPlayer.pitch_scale = sprint_multiplier
		#audioPlayer.volume_db = 5.0
		#
	else:
		# Normal animation speed
		animation_tree.set("parameters/TimeScale/scale", 1.0)
		$FootStepManager.base_player.pitch_scale =  1.0
		$FootStepManager.base_player.volume_db =   0	#
		#audioPlayer.pitch_scale = 1.0
		#audioPlayer.volume_db = 0

		
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
		
func check_health_changes(num : float):
	if sanity <= 30:
		if audioPlayer.playing:
			return
		audioPlayerNearDeath.play()
		audioPlayerNearDeath.pitch_scale = 1.4
		
	if sanity <= 0:
		audioPlayerNearDeath.pitch_scale = 1.0	
		
		play_death()
func play_death():
	await get_tree().physics_frame
	audioPlayerNearDeath.stream = load("res://art/Audio Assets/dramatic-death-collapse.mp3")
	audioPlayerNearDeath.play()
	update_animation_parameters(Vector2.ZERO)
	await get_tree().physics_frame
	
	velocity = Vector2.ZERO
	state_machine.travel("death")
	
# Sanity Logic
func RecoverSanity():
	sanity = 100
	sanity_changed.emit(sanity)
	# Hit effect manager should implement how sanity would be decreased	
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
# Sanity Logic
func ReceiveSanityDamage(dmg: float, effect_name : EnumsRef.HitEffectType):	
	if is_invulnerable:
		return
	animation_player.play("invul_got_hit")
	
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
	if $PointLight2D:
		$PointLight2D.enabled = true

func delete(item:InvItem):
	inventory.lose_item(item)


# Player adds item to his inventory	
func collect(item : InvItem):
	if item.name == "Lantern":
		turnOnLight()
		return
	elif item.itemType == EnumsRef.ItemType.ARTIFACT:
		$"AudioStreamPlayer-Obtained".play()
		artifact_collect.emit(item)
		Global.game_controller.update_artifactCheck()
		await update_artifact_text_flash()
		RecoverSanity()
		return
	GrabSound_asp.play(0.10)
	inventory.obtain(item)
func update_artifact_text_flash():
	var label: Label = $CanvasLayer/ArtifactProgress
	
	# Update text
	label.text = "Artifact: " + str(Global.artifactCount) + "/4"
	

	
	# Store original color
	var original_color: Color = label.modulate
	
	# Create flash tween
	var tween := create_tween()
	tween.tween_property(label, "modulate", Color(0, 1, 0), 0.12) # Flash green fast
	tween.tween_property(label, "modulate", Color(0, 1, 0), 0.8) # Flash green fast
	tween.tween_property(label, "modulate", original_color, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

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
func attempt_play_footsteps():
	var tile_types =[]
	var tile_data: Array[TileData] = []
	for child in get_tree().get_nodes_in_group("tilemaps"):
		var tilemap := child as TileMapLayer
		if child.tile_set.get_custom_data_layer_by_name("footstep_sfx")==-1:
			continue
		
		var tile_position := tilemap.local_to_map(tilemap.to_local(global_position))
		var data := tilemap.get_cell_tile_data(tile_position)
		
		if data:
			var tile_type = data.get_custom_data("footstep_sfx")
			var sprint := sprint_multiplier if Input.is_action_pressed("sprint") else 1.0
			$FootStepManager.play_step(global_position, tile_type, sprint)
			tile_data.push_back(data)
	#for data in tile_data:
		#if data:
			#var tile_type = data.get_custom_data("footstep_sfx")
			#if tile_type:
				#tile_types.append(tile_type)
#
	#
	#for tile_type in tile_types:
		#$FootStepManager.play_step(global_position, tile_type, sprint)
