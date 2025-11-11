class_name HitEffectManager
extends Node

var effects: Dictionary = {}

func _ready():
	# Register available effects
	effects["HitEffectDamage"] = HitEffectDamage.new()
	effects["HitEffectPoison"] = HitEffectPoison.new()
	
	
	

func apply_hit_effect(effect_name: String, amount: float, player : CharacterBody2D) -> void:
	var effect = effects.get(effect_name)
	if effect:
		effect.apply( amount, player)
	else:
		push_warning("HitEffect '%s' not found!" % effect_name)
