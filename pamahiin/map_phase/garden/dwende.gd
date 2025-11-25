extends CharacterBody2D

signal died(duwende)
signal finished_behavior(duwende)

@export var speed: float = 60.0
@export var damage: float = 5.0

# We don't need lifetime anymore, but we need an attack cooldown
var can_attack: bool = true 
var target: Node2D = null

func _ready():
	target = get_tree().get_first_node_in_group("Player")
	# (Timer code is already removed, which is good!)

func _physics_process(_delta):
	if target == null or not is_instance_valid(target):
		return

	var dir := (target.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

	# CHECK DISTANCE
	if global_position.distance_to(target.global_position) < 24:
		# Only attack if the cooldown is ready
		if can_attack:
			_perform_attack()

func _perform_attack():
	_apply_sanity_damage()
	
	# 1. Stop attacking immediately so we don't hit every frame
	can_attack = false
	
	# 2. DO NOT EMIT died.emit(self) HERE!
	# Instead, wait for 1 second before attacking again
	await get_tree().create_timer(1.0).timeout
	
	# 3. Allow attacking again
	can_attack = true

func _apply_sanity_damage():
	if target == null or not is_instance_valid(target):
		return

	if target.has_method("apply_sanity_damage"):
		target.apply_sanity_damage(damage)
	elif target.has_node("sanity_component"):
		var comp := target.get_node("sanity_component")
		if comp and comp.has_method("take_damage"):
			comp.take_damage(damage)
