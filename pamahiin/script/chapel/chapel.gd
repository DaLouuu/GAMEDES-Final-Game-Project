extends Node2D

@onready var spawnPoint : Marker2D = $"Marker2D-SpawnP"
@onready var enemy : CharacterBody2D = $EnemyAntilight


func _ready():
	enemy.start_funcs()
