class_name  WorldObject
extends Node

@export var isAlive : bool  = false
@export var isCollideable : bool  = false


func _ready() -> void:
	print("World Object loaded")
