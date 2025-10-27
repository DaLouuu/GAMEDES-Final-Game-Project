extends Node2D

@onready var player = $Player
@onready var ui = $UI

func _ready():
	# Connect signals for testing
	EventBus.sanity_changed.connect(_on_sanity_changed)
	EventBus.candle_collected.connect(_on_candle_collected)
	EventBus.ritual_completed.connect(_on_ritual_completed)
	EventBus.entity_attached.connect(_on_entity_attached)
	EventBus.sacred_zone_entered.connect(_on_sacred_zone_entered)
	EventBus.sacred_zone_exited.connect(_on_sacred_zone_exited)
	
	# Update UI initially
	ui.update_sanity_display(SanityMeter.current_sanity)
	
	# Set up candles (first 3 correct, last 2 wrong)
	var candles = $Candles.get_children()
	for i in range(candles.size()):
		candles[i].is_correct_candle = (i < 3)

func _on_sanity_changed(new_value):
	ui.update_sanity_display(new_value)
	if new_value <= 30:
		ui.show_message("SANITY CRITICAL! Find candles quickly!", Color.RED, 5.0)

func _on_candle_collected(index, is_correct):
	if is_correct:
		ui.show_message("Correct candle collected! %d/3" % Inventory.correct_candles_collected, Color.GREEN)
	else:
		ui.show_message("WRONG CANDLE! Entity attached! Sanity draining...", Color.RED)

func _on_ritual_completed():
	ui.show_message("RITUAL COMPLETE! All 3 candles found. Find the blue exit gate.", Color.GOLD, 5.0)
	$ExitGate.enable_exit()

func _on_entity_attached():
	ui.show_message("ENTITY ATTACHED! Sanity draining... Return wrong candles!", Color.PURPLE, 4.0)

func _on_sacred_zone_entered(zone_id):
	ui.show_message("Entered sacred zone - Press G to say 'Tabi-tabi po'", Color.YELLOW)

func _on_sacred_zone_exited(zone_id):
	ui.hide_interact_prompt()
