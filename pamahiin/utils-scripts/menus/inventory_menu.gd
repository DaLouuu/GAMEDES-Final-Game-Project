extends MenuBase

@onready var item_list = $Panel/ScrollContainer/ItemList
@onready var close_button = $Panel/Close
var player

func _ready():
	super._ready()
	close_button.pressed.connect(close)
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta):
	if Input.is_action_just_pressed("inventory_menu"):
		toggle()
	if is_open:
		_refresh_inventory()

func _refresh_inventory():
	if not player or not player.has_variable("inventory"):
		return
	item_list.queue_free_children()
	for item in player.inventory:
		var label = Label.new()
		label.text = str(item)
		item_list.add_child(label)
