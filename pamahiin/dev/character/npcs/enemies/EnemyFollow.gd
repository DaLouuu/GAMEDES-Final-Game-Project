class_name EnemyFollow
extends State

@export var move_speed: float = 300.0
@export var lost_threshold: float = 3.0  # seconds before giving up
@onready var vision_ray: RayCast2D = enemy.get_node("VisionRay")
@onready var player_detector = $"../../PlayerDetector"
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

# initial count of enemy would lose track of player
@export var lose_timer: float = 0.0
@export var move_behavior: MoveType
@export var hit_distance : int  = 20

func Enter() -> void:
	print("Enemy following player.")
	lose_timer = 0.0

func Physics_Update(delta: float) -> void:
	if not player or not enemy:
		return

	# --- Update ray to point toward the player ---
	var has_clear_sight := false
	vision_ray.look_at(player.global_position)
	vision_ray.force_raycast_update()
	
	
	# VisionRay Collision Logic
	if vision_ray.is_colliding():
		var collider = vision_ray.get_collider()
		print("Hit:", collider)
		if collider and collider.is_in_group("EnemyVisionBlock"):
			has_clear_sight = false
		else:
			has_clear_sight = true	


					
	# --- Behavior logic ---
	if has_clear_sight:
		# Reset lose timer since player is visible
		lose_timer = 0.0
		
		# Movement
		var move_vec = move_behavior.get_move_vector(enemy,player,delta)
		enemy.velocity = move_vec
		#enemy.move_and_slide()
		enemy.move_and_collide(enemy.velocity * delta)
		

	else:
		# Can't see player, count up timer
		
		lose_timer += delta
		print("Can't see player: ", lose_timer)
		
		if lose_timer >= lost_threshold:
			Transitioned.emit(self, "EnemyIdle")
			print("Lost sight of player — switching to idle.")
			
	
	# Theres two types of damage currently HitEffectPoison and HitEffectDamage		
	if enemy.global_position.distance_to(player.global_position) < hit_distance:
		player.ReceiveSanityDamage(30.0, "HitEffectPoison")		

func Exit() -> void:
	enemy.velocity = Vector2.ZERO
