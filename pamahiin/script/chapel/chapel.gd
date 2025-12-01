extends Node2D

@onready var spawnPoint : Marker2D = $"Marker2D-SpawnP"
var correct_order = ["ChapelCandle4-Answer2", "ChapelCandle6-Answer3", 
"ChapelCandle2-Answer4", "ChapelCandle3-Answer5", "ChapelCandle5-Answer6", "ChapelCandle-Answer7"]
var current_step = 0
#@onready var enemy : CharacterBody2D = $EnemyAntilight


func _ready():
	$"ItemTemplate-chalice".item_inspected.connect(start_enemies)
	var node = $TileMap/Animatable_puzzle
	var tween = create_tween().set_loops()  # Repeat forever
	for child in $LightGroup.get_children():
		var candle := child as ChapelCandle
		candle.interacted.connect(_on_light_pressed.bind(child.name))
		candle.lights_off.connect(reset_sequence_lights)
	# 1. Flicker opacity (visible → invisible → visible)
	tween.tween_property(node, "modulate:a", 0.25, 1.0)  # fade to 50% in 0.5s
	tween.tween_property(node, "modulate:a", 2.5, 1.0)  # fade back to full in 0.5s
func start_enemies(_item: InvItem):
	$EnemyAntilight.start_funcs()
	$EnemyAntilight2.start_funcs()
	$EnemyAntilight3.start_funcs()
	
func _on_light_pressed(light_name):
	if light_name == correct_order[current_step]:
		# Correct light
		highlight_correct(light_name)
		current_step += 1

		if current_step >= correct_order.size():
			puzzle_solved()
	else:
		# Wrong light → reset
		reset_sequence()
func reset_sequence_lights():
	print("Lights ran out, resetting puzzle...")
	current_step = 0
	reset_lights_visual()
func reset_sequence():
	print("Wrong light, resetting puzzle...")
	current_step = 0
	reset_lights_visual()

func puzzle_solved():
	print("Puzzle complete!")
	emit_signal("puzzle_completed") # optional

func highlight_correct(light_name):
	for c in $LightGroup.get_children():
		if light_name == c.name:
			var node = c
			node.modulate = Color(0,1,0) # green flash

func reset_lights_visual():
	for c in $LightGroup.get_children():
		c.modulate = Color(1,1,1) # green flash
		var candle := c as ChapelCandle
		candle.play_stop()
