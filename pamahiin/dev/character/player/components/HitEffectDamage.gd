class_name HitEffectDamage
extends HitEffect

func apply(target: Node, data: Dictionary) -> void:
	if not target.has_method("ReceiveSanityDamage"):
		push_warning("Target cannot receive sanity damage.")
		return
	var amount = data.get("amount", 0)
