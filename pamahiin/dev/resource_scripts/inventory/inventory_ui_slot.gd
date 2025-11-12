class_name InventoryUISlot
extends Panel

@onready var _item_display: TextureRect = $MarginContainer/ItemDisplay
@onready var _count_display: Label = $MarginContainer2/Control/CountDisplay

@export var slot_info: InvSlot:
	get:
		return slot_info
		
	set(v):
		if is_node_ready():
			_update_display()
		
		slot_info = v

func _ready() -> void:
	_update_display()

func _update_display() -> void:
	_item_display.texture = slot_info.item.texture
	_count_display.text = str(slot_info.count)
