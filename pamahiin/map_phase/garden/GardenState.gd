extends Node
class_name GardenState

# ---------------------------------------------------------
# SIGNALS
# ---------------------------------------------------------
signal state_ready
signal correct_trees_changed(new_set: Array)       # Trees listen to this
signal trunk_swap_triggered(step: int)             # Trees/Controller listen to this
signal mistake_changed(new_value: int)             # Signages/Whispers listen to this


# ---------------------------------------------------------
# STATE VARIABLES
# ---------------------------------------------------------

var is_ready: bool = false

# TREE PUZZLE
var cicadas_active: bool = false

# EXPORTED FOR TESTING:
# Add ["wind", "spiral", "eye", "tally", "hollow"] in Inspector to test collecting 5 sticks.
@export var correct_tree_markings: Array[String] = []

var zone_a_completed: bool = false

# STICK COLLECTION
var total_sticks_collected: int = 0

# WELL & BROOM
var has_rope: bool = false
var broom_crafted: bool = false

# MISTAKES
var mistake_count: int = 0
var trunk_swap_step: int = 0   # increments every 3 mistakes

# AMBIENCE
var fog_density: float = 0.25
var ambience_enabled: bool = false


# ---------------------------------------------------------
# READY
# ---------------------------------------------------------
func _ready():
	is_ready = true
	
	# INITIALIZE PUZZLE
	# If you set trees in the Inspector, use those. Otherwise, random.
	if correct_tree_markings.is_empty():
		_randomize_correct_trees()
	else:
		print("[GardenState] Using Inspector settings for trees: ", correct_tree_markings)
		# We must defer the signal slightly to ensure listeners are ready
		call_deferred("emit_signal", "correct_trees_changed", correct_tree_markings)
	
	emit_signal("state_ready")
	print("[GardenState] Initialized.")


# ---------------------------------------------------------
#  MISTAKE SYSTEM
# ---------------------------------------------------------
func add_mistake():
	mistake_count += 1
	emit_signal("mistake_changed", mistake_count)

	print("[GardenState] mistake_count =", mistake_count)

	# Every 3 mistakes → cycle tree trunks & correct answers
	if mistake_count % 3 == 0:
		trunk_swap_step += 1
		emit_signal("trunk_swap_triggered", trunk_swap_step)
		
		# Only re-randomize if we aren't manually testing specific trees
		if correct_tree_markings.is_empty() or correct_tree_markings.size() == 1:
			_randomize_correct_trees()


# ---------------------------------------------------------
# RANDOMIZE CORRECT TREES
# ---------------------------------------------------------
func _randomize_correct_trees():
	var marking_pool = ["wind", "spiral", "eye", "tally", "hollow"]
	marking_pool.shuffle()

	# Pick 1 correct tree per cycle
	correct_tree_markings = [marking_pool[0]]

	# Emit signal so trees update themselves
	emit_signal("correct_trees_changed", correct_tree_markings)
	print("[GardenState] correct_tree_markings updated:", correct_tree_markings)


# ---------------------------------------------------------
# RESET
# ---------------------------------------------------------
func reset():
	cicadas_active = false
	
	# Reset puzzle
	trunk_swap_step = 0
	mistake_count = 0
	_randomize_correct_trees()

	zone_a_completed = false
	total_sticks_collected = 0

	has_rope = false
	broom_crafted = false

	fog_density = 0.25
	ambience_enabled = false

	print("[GardenState] Reset to defaults.")
