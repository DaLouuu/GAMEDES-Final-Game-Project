extends CharacterBody2D

const SFX_MAP = {
	"ground": preload("uid://ddty6kh3k1x7p"),
	"salt": preload("uid://qnqi6x0wy5g7")
}

@export var move_speed : float =  50
@export var sprint_multiplier : float = 1.8

# TODO: This should be global and independent of the player
@onready var _tile_maps: Node2D = $"../TileMaps"

var _is_playing = {
	"ground": false,
	"salt": false
}

# Anything moving and colliding is always under the collision
func _physics_process(_delta: float) -> void:
	# Smart logic cancelling inputs of both directional keys
	var input_direction := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up") 
	)

	# Sprinting multiplier
	var current_speed := move_speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier
	
	velocity = input_direction * current_speed
	
	move_and_slide()
	
	#if velocity.length_squared() > 0:
		#_play_footsteps()
		
func _play_footsteps() -> void:
	var tile_data: Array[TileData] = []
	
	for child in _tile_maps.get_children():
		var tilemap := child as TileMapLayer
		
		var tile_position := tilemap.local_to_map(position)
		var data := tilemap.get_cell_tile_data(tile_position)
		
		if data:
			tile_data.push_back(data)
			
	if tile_data.size() > 0:
		var tile_type = tile_data.back().get_custom_data('footstep_sound')
		
		if SFX_MAP.has(tile_type) and not _is_playing[tile_type]:
			var audio_player := AudioStreamPlayer2D.new()
			audio_player.stream = SFX_MAP[tile_type]
			
			get_tree().root.add_child(audio_player)
			audio_player.global_position = position
			audio_player.volume_db = -5
			audio_player.play()
			
			_is_playing[tile_type] = true
			
			await audio_player.finished
			audio_player.queue_free()
			
			_is_playing[tile_type] = false
