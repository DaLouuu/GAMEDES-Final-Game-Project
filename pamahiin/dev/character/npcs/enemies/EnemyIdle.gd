class_name EnemyIdle extends State

@export var move_speed := 20

var move_direction : Vector2
var wander_time
@onready var vision_ray: RayCast2D = enemy.get_node("VisionRay")
@onready var player_detector: Area2D = enemy.get_node("PlayerDetector")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

func randomize_wander():
	
	move_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1,3)

func Enter():
	player_detector.body_entered.connect(_on_body_entered)
	randomize_wander()	
	
	
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		print("Player detected — switching to follow.")
		Transitioned.emit(self, "EnemyFollow")
		var to_player = player.global_position - enemy.global_position
		vision_ray.target_position = to_player
		vision_ray.force_raycast_update()
		
func Update(delta:float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()
func Physics_Update(_delta:float):
	if not enemy || not player:
		return
	# 🔍 Update ray direction toward player
		
	enemy.velocity = move_direction * move_speed
		
