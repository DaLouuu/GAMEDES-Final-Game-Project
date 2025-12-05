extends Node
class_name GardenState

# ---------------------------------------------------------
# SIGNALS
# ---------------------------------------------------------
signal state_ready
signal correct_trees_changed(new_set: Array)
signal mistake_changed(new_value: int)
signal boulder_unlocked

# ---------------------------------------------------------
# STATE VARIABLES
# ---------------------------------------------------------
var is_ready: bool = false
var cicadas_active: bool = false

# EXPORTED SETTINGS
@export var correct_tree_markings: Array[String] = []

var zone_a_completed: bool = false
var total_sticks_collected: int = 0
var has_rope: bool = false
var broom_crafted: bool = false

# MISTAKES & FOG
var mistake_count: int = 0
var fog_density: float = 0.25
var ambience_enabled: bool = false


func _ready():
	add_to_group("GardenState")
	is_ready = true
	
	if correct_tree_markings.is_empty():
		_randomize_correct_trees()
	else:
		print("[GardenState %s] Using Inspector settings: %s" % [get_instance_id(), correct_tree_markings])
		call_deferred("emit_signal", "correct_trees_changed", correct_tree_markings)
	
	emit_signal("state_ready")
	print("[GardenState %s] Initialized." % get_instance_id())


func add_mistake():
	mistake_count += 1
	emit_signal("mistake_changed", mistake_count)
	print("[GardenState] mistake_count =", mistake_count)
	
	# Note: Fog update happens in ZoneAController based on this count
	
	# Only re-randomize if we aren't manually testing specific trees
	if correct_tree_markings.is_empty() or correct_tree_markings.size() == 1:
		_randomize_correct_trees()


func _randomize_correct_trees():
	var marking_pool = ["wind", "spiral", "eye", "tally", "hollow"]
	marking_pool.shuffle()
	correct_tree_markings = [marking_pool[0]]
	emit_signal("correct_trees_changed", correct_tree_markings)
	print("[GardenState] correct_tree_markings updated:", correct_tree_markings)


func trigger_boulder_unlock():
	emit_signal("boulder_unlocked")
	print("[GardenState] Boulder unlock signal emitted.")


func reset():
	cicadas_active = false
	mistake_count = 0
	_randomize_correct_trees()
	zone_a_completed = false
	total_sticks_collected = 0
	has_rope = false
	broom_crafted = false
	fog_density = 0.25
	ambience_enabled = false
	print("[GardenState] Reset to defaults.")
