extends CanvasLayer 

@onready var panel = $Panel 
@onready var sanity_slider = $Panel/SanitySlider 
@onready var teleport_dropdown = $Panel/TeleportDropdown 

func _ready(): 
	panel.visible = false 
	sanity_slider.value = SanityMeter.current_sanity 
	
	# Add teleport 
	teleport_dropdown.add_item("Spawn") 
	teleport_dropdown.add_item("Shrine") 
	teleport_dropdown.add_item("Exit") 

func _input(event): 
	if event.is_action_pressed("cheat_menu"): 
		toggle_menu() 

func toggle_menu(): 
	panel.visible = !panel.visible 
	get_tree().paused = panel.visible 

func _on_SanitySlider_value_changed(value): 
	SanityMeter.current_sanity = value 
	EventBus.sanity_changed.emit(value) 

func _on_AddCandle_pressed(): 
	Inventory.collect_candle(true) 

func _on_TeleportButton_pressed(): 
	var location = teleport_dropdown.get_item_text(teleport_dropdown.selected) 
	# Basic teleport test - actual coordinates needed 
	print("Teleporting to: ", location) 

func _on_CloseButton_pressed(): 
	toggle_menu() 
