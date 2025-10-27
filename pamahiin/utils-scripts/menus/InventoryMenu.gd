extends CanvasLayer 

@onready var panel = $Panel 

func _ready():
	panel.visible = false

func _input(event):
	if event.is_action_pressed("inventory_menu"):
		toggle_menu()

func toggle_menu():
	panel.visible = !panel.visible
	# Don't pause for inventory menu
	
	if panel.visible:
		update_display()

func update_display():
	# Debug info about inventory state
	$Panel/DebugLabel.text = "Candles: %d/3\nEntity Attached: %s" % [
		Inventory.correct_candles_collected,
		SanityMeter.is_entity_attached
	]

func _on_CloseButton_pressed():
	toggle_menu()
