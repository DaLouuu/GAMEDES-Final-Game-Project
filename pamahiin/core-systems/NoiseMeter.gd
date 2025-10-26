extends Node

var current_noise := 0.0 
var max_noise := 100.0 
var noise_decay_rate := 15.0 
var threshold := 65.0 

var is_entity_hunting := false 
var hunt_timer := 0.0 

func _process(delta): 
	# Decay noise 
	current_noise = max(0, current_noise - noise_decay_rate * delta) 
	
	# Entity hunt 
	if is_entity_hunting: 
		hunt_timer -= delta 
		if hunt_timer <= 0: 
			is_entity_hunting = false 
			EventBus.entity_hunt_ended.emit() 

func add_noise(amount: float): 
	current_noise = min(max_noise, current_noise + amount) 
	
	if current_noise >= threshold and not is_entity_hunting: 
		is_entity_hunting = true 
		hunt_timer = randf_range(5.0, 10.0) # 5-10 second hunt 
		EventBus.noise_threshold_exceeded.emit() 
