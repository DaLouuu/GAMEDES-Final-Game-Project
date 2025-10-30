extends MenuBase

@onready var panel = $PanelContainer
@onready var left_button = $HBoxContainer2/LeftButton  # Rename to "LeftButton" if desired
@onready var right_button = $HBoxContainer2/RightButton
@onready var slots_container = $VBoxContainer/HBoxContainer
@onready var slot_sprites := [
	slots_container.get_child(0),
	slots_container.get_child(1),
	slots_container.get_child(2),
	slots_container.get_child(3)
]

var player
var inventory := []
var current_index := 0  # first visible slot index

func _ready():
	super._ready()
	player = get_tree().get_first_node_in_group("Player")

	left_button.pressed.connect(_on_left_pressed)
	right_button.pressed.connect(_on_right_pressed)

	visible = false
	_update_display()

func _process(_delta):
	if Input.is_action_just_pressed("inventory_menu"):
		toggle()
	if is_open:
		_refresh_inventory()

# --- Inventory Refresh ---
func _refresh_inventory():
	if not player or not player.has_variable("inventory"):
		return
	inventory = player.inventory
	_update_display()

# --- Display Logic ---
func _update_display():
	# Hide all slots first
	for i in range(slot_sprites.size()):
		slot_sprites[i].texture = null
		slot_sprites[i].modulate = Color(1, 1, 1, 0.3)  # dim if empty

	# Fill visible slots (up to 4)
	for i in range(4):
		var inv_index = current_index + i
		if inv_index < inventory.size():
			var item = inventory[inv_index]
			slot_sprites[i].modulate = Color(1, 1, 1, 1)
			slot_sprites[i].texture = item.icon if item.has("icon") else null

	# Update arrow visibility
	left_button.modulate.a = 1.0 if current_index > 0 else 0.3
	right_button.modulate.a = 1.0 if current_index + 4 < inventory.size() else 0.3

# --- Navigation ---
func _on_left_pressed():
	if current_index > 0:
		current_index -= 1
		_update_display()

func _on_right_pressed():
	if current_index + 4 < inventory.size():
		current_index += 1
		_update_display()
