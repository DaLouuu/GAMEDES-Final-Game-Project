class_name EnemyFollow
extends State

@export var move_speed: float = 40.0
@export var lost_threshold: float = 3.0  # seconds before giving up

var lose_timer: float = 0.0
@onready var vision_ray: RayCast2D = enemy.get_node("VisionRay")
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

func Enter() -> void:
	print("Enemy following player.")
	lose_timer = 0.0

func Physics_Update(delta: float) -> void:
	if not player or not enemy:
		return

	# --- Update ray to point toward the player ---
	var to_player = player.global_position - enemy.global_position
	vision_ray.target_position = to_player
	vision_ray.force_raycast_update()

	var has_clear_sight := false
	if vision_ray.is_colliding():
		var collider = vision_ray.get_collider()
		if collider and collider.is_in_group("Player"):
			has_clear_sight = true

	else:
		# If not colliding, ray did not hit anything (possibly clear path)
		# You can choose to assume it means "clear" if distance is short
		if enemy.global_position.distance_to(player.global_position) < 300:
			has_clear_sight = true
		
	# --- Behavior logic ---
	if has_clear_sight:
		# Reset lose timer since player is visible
		lose_timer = 0.0
		var direction = (player.global_position - enemy.global_position).normalized()
		enemy.velocity = direction * move_speed
		enemy.move_and_slide()
		if enemy.global_position.distance_to(player.global_position) < 20:
			player.ReceiveSanityDamage(25, "HitEffectDamage")
	else:
		# Can't see player, count up timer
		
		lose_timer += delta
		
		if lose_timer >= lost_threshold:
			Transitioned.emit(self, "EnemyIdle")
			print("Lost sight of player — switching to idle.")
			

func Exit() -> void:
	enemy.velocity = Vector2.ZERO
