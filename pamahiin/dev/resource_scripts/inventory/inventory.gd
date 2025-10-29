class_name Inventory
extends Resource

signal update

@export var slots: Array[InvSlot]

func insert(item: InvItem):

	var emptyslots = slots.filter(func(slot): return slot.item==null)
	if !emptyslots.is_empty():
		emptyslots[0].item = item
		
		
	update.emit()
	
