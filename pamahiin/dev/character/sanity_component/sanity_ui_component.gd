class_name SanityUIComponent
extends Control

@onready var bar = $HBoxContainer/TextureProgressBar  # or self if it *is* the bar
var player: Node = null

func _ready():
	# find player dynamically
	player = get_tree().get_first_node_in_group("Player")
	if player:
		player.sanity_changed.connect(_on_sanity_changed)
		# Initialize with current value
		_on_sanity_changed(player.sanity)

func _on_sanity_changed(value: float):
	if bar:
		bar.create_tween().tween_property(bar, "value", value, 0.3)
