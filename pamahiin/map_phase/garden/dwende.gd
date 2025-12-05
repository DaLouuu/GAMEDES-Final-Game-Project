extends CharacterBody2D

signal died(duwende)

@export var base_speed: float = 110.0
@export var chase_speed: float = 140.0
@export var damage: float = 10.0
@export var attack_cooldown: float = 1.0
@export var chase_attack_cooldown: float = 0.5

var can_attack: bool = true
var target: Node2D = null

func _ready():
	add_to_group("duwende")
	target = get_tree().get_first_node_in_group("Player")
	
	# Buff based on mistakes
	var gs = get_tree().get_first_node_in_group("GardenState")
	if gs and "mistake_count" in gs:
		base_speed *= (1.0 + min(gs.mistake_count, 10) * 0.03)

func _physics_process(delta):
	# 1. Target Safety
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("Player")
		return

	# 2. Check Chase State
	var chase_manager = get_tree().get_first_node_in_group("GardenChaseManager")
	var chasing := false
	if chase_manager and "chase_active" in chase_manager:
		chasing = chase_manager.chase_active

	# --- FIX: STOP MOVING IF ATTACKING ---
	# This prevents them from sliding past you or "running away" due to physics collisions
	if not can_attack:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# 3. Move Towards Player
	# "direction_to" ensures it always points FROM self TO target
	var direction = global_position.direction_to(target.global_position)
	
	var speed = base_speed
	if chasing:
		speed = chase_speed
	
	velocity = direction * speed
	move_and_slide()

	# 4. Attack Logic
	var dist = global_position.distance_to(target.global_position)
	
	# Distance < 30 is touch range
	if dist < 30 and can_attack:
		_perform_attack(chasing)

func _perform_attack(is_chasing: bool):
	# 1. Apply Damage
	if target.has_method("ReceiveSanityDamage"):
		target.ReceiveSanityDamage(damage, 0)
	elif target.has_method("apply_sanity_damage"):
		target.apply_sanity_damage(damage)
	elif target.has_node("sanity_component"):
		target.get_node("sanity_component").take_damage(damage)
	
	# 2. Start Cooldown (Stops movement due to check in physics_process)
	can_attack = false
	
	var cooldown_time = attack_cooldown
	if is_chasing:
		cooldown_time = chase_attack_cooldown
		
	await get_tree().create_timer(cooldown_time).timeout
	
	# 3. Resume Chasing
	can_attack = true
