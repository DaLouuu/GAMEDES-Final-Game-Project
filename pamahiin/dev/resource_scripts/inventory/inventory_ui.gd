extends Control

const INVENTORY_SLOT_SCN = preload("uid://csd3b5o4mm6y7")

@export var inventory: Inventory

@onready var _item_container: HBoxContainer = $ItemContainer

func _ready():
	_update_inventory_slots()
	inventory.updated.connect(_update_inventory_slots)

func _update_inventory_slots() -> void:
	# Dumb approach: clear and re-set everything
	for slot_ui in _item_container.get_children():
		_item_container.remove_child(slot_ui)
		slot_ui.queue_free()
	
	for slot in inventory.slots:
		
		var slot_ui: InventoryUISlot = INVENTORY_SLOT_SCN.instantiate(PackedScene.GEN_EDIT_STATE_MAIN_INHERITED)
		slot_ui.slot_info = slot
	
		_item_container.add_child(slot_ui)
