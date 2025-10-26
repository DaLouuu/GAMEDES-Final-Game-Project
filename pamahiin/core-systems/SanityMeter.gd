extends Node

@export_range(0, 100) var current_sanity := 100.0 
@export_range(0, 100) var max_sanity := 100.0 

var is_entity_attached := false 
var entity_drain_rate := 1.0 # % per second when attached 

func _ready(): 
	EventBus.entity_attached.connect(_on_entity_attached)
	EventBus.ritual_completed.connect(_on_ritual_completed)

func _process(delta): 
	if is_entity_attached: 
		decrease_sanity(entity_drain_rate * delta)

func decrease_sanity(amount: float): 
	current_sanity = max(0, current_sanity - amount) 
	EventBus.sanity_changed.emit(current_sanity) 
	
	if current_sanity <= 0: 
		EventBus.sanity_depleted.emit() 
	elif current_sanity <= 30: 
		EventBus.sanity_low.emit("high") 
	elif current_sanity <= 50: 
		EventBus.sanity_low.emit("medium")

func increase_sanity(amount: float): 
	current_sanity = min(max_sanity, current_sanity + amount) 
	EventBus.sanity_changed.emit(current_sanity)

func _on_entity_attached(): 
	is_entity_attached = true

func _on_ritual_completed(): 
	increase_sanity(15) # Reward 
	is_entity_attached = false
