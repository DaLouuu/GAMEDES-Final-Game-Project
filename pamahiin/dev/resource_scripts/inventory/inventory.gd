class_name Inventory
extends Resource

signal updated

@export var slots: Array[InvSlot] = []

func lose_slot(idx: int, count: int = 1) -> void:
	assert(count > 0, "Cannot lose an item < 1 times.")
	assert(idx >= 0 and idx < slots.size(), "Index of slot to lose invalid.")
	
	slots[idx].count -= count
	
	if slots[idx].count <= 0:
		slots.remove_at(idx)
	
	updated.emit()

func lose_item(item: InvItem, count: int = 1) -> void:
	assert(count > 0, "Cannot lose an item < 1 times.")
	
	var existing_slot_idx := slots.find_custom(func (s): return s.item == item)
	
	if existing_slot_idx == -1:
		push_error("Attempted to lose nonexistent item.")
		return
	
	lose_slot(existing_slot_idx, count)

func obtain(item: InvItem, count: int = 1) -> void:
	assert(count > 0, "Cannot obtain an item < 1 times.")
	
	var existing_slot_idx := slots.find_custom(func (s): return s.item == item)
	if existing_slot_idx == -1:
		var new_slot := InvSlot.new()
		new_slot.item = item
		new_slot.count = count
		slots.append(new_slot)
	else:
		var old_slot = slots[existing_slot_idx]
		old_slot.count += count

	updated.emit()
