extends Node

##
##  GARDEN PHASE - LOCAL GLOBAL STATE
##

# ----- ZONE A -----
var cicadas_active: bool = false
var correct_tree_marking: String = "wind"
var zone_a_completed: bool = false
var found_stick_zone_a: bool = false

# ----- ZONE B -----
var zone_b_completed: bool = false
var found_stick_zone_b: bool = false

# ----- ZONE C -----
var hum_target: int = 0
var zone_c_completed: bool = false
var found_stick_zone_c: bool = false

# ----- STICK COUNT -----
var total_sticks_collected: int = 0

# ----- FOG / AMBIENCE -----
var fog_density: float = 0.25
var ambience_enabled: bool = false


func reset():
	# ZONE A
	cicadas_active = false
	correct_tree_marking = "wind"
	zone_a_completed = false
	found_stick_zone_a = false

	# ZONE B
	zone_b_completed = false
	found_stick_zone_b = false

	# ZONE C
	hum_target = 0
	zone_c_completed = false
	found_stick_zone_c = false

	# TOTAL
	total_sticks_collected = 0

	# AMBIENCE
	fog_density = 0.25
	ambience_enabled = false
