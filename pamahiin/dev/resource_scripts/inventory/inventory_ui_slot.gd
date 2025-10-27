extends Panel

@onready var item_visual: TextureRect = $CenterContainer/Panel/ItemDisplay


func update(slot: InvSlot):
	if !slot:
		item_visual.visible = false
	else:
		item_visual.visible = true
		if slot.item:
			item_visual.texture = slot.item.texture
