extends CharacterBody2D

signal died(duwende)
signal finished_behavior(duwende)

@export var base_speed: float = 60.0
@export var chase_speed: float = 120.0
@export var base_damage: float = 5.0
@export var chase_damage: float = 12.0

@export var attack_cooldown: float = 1.0
@export var chase_attack_cooldown: float = 0.5

var can_attack := true
var target: Node2D = null


func _ready():
	add_to_group("duwende")
	target = get_tree().get_first_node_in_group("Player")

	# Optional buff based on mistakes BEFORE chase
	var gs = get_tree().get_first_node_in_group("GardenState")
	if gs:
		base_speed *= (1.0 + min(gs.mistake_count, 10) * 0.03)


func _physics_process(delta):
	if target == null or not is_instance_valid(target):
		return

	var chase_manager = get_tree().get_first_node_in_group("GardenChaseManager")
	var chasing := false
	if chase_manager:
		chasing = chase_manager.chase_active

	# ----------------------------
	# MOVEMENT
	# ----------------------------
	var speed: float = base_speed
	if chasing:
		speed = chase_speed

	var direction := (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	# ----------------------------
	# ATTACK
	# ----------------------------
	var dist := global_position.distance_to(target.global_position)

	if dist < 26 and can_attack:
		_perform_attack(chasing)


func _perform_attack(is_chasing: bool):
	var dmg: float = base_damage
	if is_chasing:
		dmg = chase_damage

	_apply_sanity_damage(dmg)

	can_attack = false

	var cooldown: float = attack_cooldown
	if is_chasing:
		cooldown = chase_attack_cooldown

	await get_tree().create_timer(cooldown).timeout
	can_attack = true


func _apply_sanity_damage(amount: float):
	if target == null or not is_instance_valid(target):
		return

	if target.has_method("apply_sanity_damage"):
		target.apply_sanity_damage(amount)
	elif target.has_node("sanity_component"):
		var comp := target.get_node("sanity_component")
		if comp and comp.has_method("take_damage"):
			comp.take_damage(amount)
