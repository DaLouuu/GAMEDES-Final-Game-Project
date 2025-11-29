extends AudioStreamPlayer2D


@export var near_distance: float = 50.0   # Distance where sound is quietest
@export var far_distance: float = 500.0   # Distance where sound is loudest

@export var near_volume_db: float = -60.0
@export var far_volume_db: float = 0.0

func _ready() -> void:
	# Disable built-in attenuation to prevent fighting with our script
	attenuation = 0.0
	
func _process(_delta: float) -> void:
	var target_node: Player = _get_player()
	var current_dist = global_position.distance_to(target_node.global_position)
	
	# Calculate a value between 0.0 and 1.0 based on distance
	# 0.0 = at or closer than near_distance
	# 1.0 = at or further than far_distance
	var ratio = (current_dist - near_distance) / (far_distance - near_distance)
	ratio = clamp(ratio, 0.0, 1.0)
	
	volume_db = lerp(near_volume_db, far_volume_db, ratio)
	print(get_path(), volume_db)


func _get_player() -> Player:
	if not is_inside_tree():
		return
	
	var player := get_tree().get_first_node_in_group("Player")
	assert(player != null, "No player in scene!")
	return player
