extends Node

# Sanity events 
signal sanity_changed(new_value)
signal sanity_low(warning_level)
signal sanity_depleted

# Inventory events 
signal inventory_updated
signal candle_collected(candle_index, is_correct)
signal candle_used(candle_index) 

# Gameplay events 
signal sacred_zone_entered(zone_id) 
signal sacred_zone_exited(zone_id) 
signal noise_threshold_exceeded 
signal entity_attached 
signal entity_hunt_ended
signal ritual_completed 

# Input events
signal player_greeted 
signal player_interacted(object_type) 
signal player_looked_back 
