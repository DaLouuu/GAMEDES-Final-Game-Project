extends CanvasLayer 

@onready var sanity_label = $HUD/SanityLabel 
@onready var interact_prompt = $HUD/InteractPrompt 
@onready var message_label = $HUD/MessageLabel 
@onready var message_timer = $HUD/MessageLabel/MessageTimer 
@onready var inventory_display = $HUD/InventoryDisplay 

func _ready(): 
	# Create inventory slots 
	for i in range(3): 
		var slot = ColorRect.new() 
		slot.size = Vector2(30, 30) 
		slot.position = Vector2(i * 40, 0) 
		slot.color = Color.GRAY 
		slot.name = "Slot%d" % i 
		inventory_display.add_child(slot) 
	
	EventBus.candle_collected.connect(_on_candle_collected) 
	hide_interact_prompt() 

func update_sanity_display(sanity_value: float): 
	sanity_label.text = "Santiy: %.0f%%" % sanity_value 
	
	# Color coding 
	if sanity_value > 70: 
		sanity_label.modulate = Color.GREEN 
	elif sanity_value > 30: 
		sanity_label.modulate = Color.YELLOW 
	else: 
		sanity_label.modulate = Color.RED

func show_interact_prompt(text: String): 
	interact_prompt.text = text
	interact_prompt.visible = true

func hide_interact_prompt(): 
	interact_prompt.visible = false 

func show_message(text: String, color: Color = Color.WHITE): 
	message_label.text = text 
	message_label.modulate = color 
	message_label.visible = true 
	message_timer.start(3.0)

func _on_candle_collected(index: int, is_correct: bool): 
	var slot = inventory_display.get_node("Slot%d" % index) 
	if is_correct: 
		slot.color = Color.WHITE 
	else: 
		slot.color = Color.RED

func _on_MessageTimer_timeout(): 
	message_label.visible = false
