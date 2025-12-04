class_name Enemy
extends CharacterBody2D

signal begin_behaviors
signal stop_behaviors
@export var damage_to_player: float = 30.0
@export var follow_speed: float = 300.0
@export var move_speed: float = 200.0
@export var detection_radius: float = 120.0
@export var wander_interval: float = 2.0
@export var move_behavior: MoveType
@export var scale_move : float = 1.0
@export var hit_effect_type : EnumsRef.HitEffectType = EnumsRef.HitEffectType.HitEffectDamage
@export var hit_distance : float = 20.0 
@onready var PlayerDetector: Area2D = $PlayerDetector
@onready var vision_ray : RayCast2D = $VisionRay
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine= animation_tree.get("parameters/playback")
@onready var collision_shape : CollisionShape2D = $CollisionShape2D

func start_funcs():
	begin_behaviors.emit()
	
func stop_funcs():
	stop_behaviors.emit()
	
func _physics_process(_delta: float) -> void:
	move_and_slide()
	
