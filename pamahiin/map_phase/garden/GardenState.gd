extends Node
class_name GardenState

# ---------------------------------------------------------
# SIGNALS
# ---------------------------------------------------------
signal state_ready
signal correct_trees_changed(new_set: Array)       # ZoneAController listens to this
signal trunk_swap_triggered(step: int)             # Every 3 mistakes → trunk change
signal mistake_changed(new_value: int)             # Useful for whispers / signages


# ---------------------------------------------------------
# STATE VARIABLES
# ---------------------------------------------------------

var is_ready: bool = false

# TREE PUZZLE
var cicadas_active: bool = false
var correct_tree_markings: Array[String] = ["wind"]    # now supports multiple correct trees
var zone_a_completed: bool = false
var found_stick_zone_a: bool = false

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
	emit_signal("state_ready")
	print("[GardenState] Initialized.")


# ---------------------------------------------------------
#  MISTAKE SYSTEM — called by ZoneAController on wrong knock
# ---------------------------------------------------------
func add_mistake():
	mistake_count += 1
	emit_signal("mistake_changed", mistake_count)

	print("[GardenState] mistake_count =", mistake_count)

	# Every 3 mistakes → cycle tree trunks & correct answers
	if mistake_count % 3 == 0:
		trunk_swap_step += 1
		emit_signal("trunk_swap_triggered", trunk_swap_step)
		_randomize_correct_trees()


# ---------------------------------------------------------
# RANDOMIZE CORRECT TREES AFTER MAJOR MISTAKES
# ---------------------------------------------------------
func _randomize_correct_trees():
	var marking_pool = ["wind", "spiral", "eye", "tally", "hollow"]
	marking_pool.shuffle()

	# pick 1 correct tree per cycle (can be more if you want)
	correct_tree_markings = [marking_pool[0]]

	print("[GardenState] correct_tree_markings updated:", correct_tree_markings)
	emit_signal("correct_trees_changed", correct_tree_markings)


# ---------------------------------------------------------
# RESET (optional use)
# ---------------------------------------------------------
func reset():
	cicadas_active = false
	correct_tree_markings = ["wind"]
	zone_a_completed = false
	found_stick_zone_a = false

	total_sticks_collected = 0

	has_rope = false
	broom_crafted = false

	mistake_count = 0
	trunk_swap_step = 0

	fog_density = 0.25
	ambience_enabled = false

	print("[GardenState] Reset to defaults.")
