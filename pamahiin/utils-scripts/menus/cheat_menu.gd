extends MenuBase

@onready var vbox = $Panel/ScrollContainer/PanelContainer/VBoxContainer
@onready var teleport_label = vbox.get_node_or_null("RichTextLabel") # the label above ItemList
@onready var teleport_list = vbox.get_node_or_null("ItemList")

var toggles := {
	"god_mode": false,
	"hostiles": true,
	"take_damage": true
}

# Example teleport destinations (adjust as needed)
var teleport_map := {
	"garden": "res://map_phase/garden/garden.tscn",
	"graveyard": "res://map_phase/graveyard/graveyard.tscn",
	"house 1": "res://map_phase/house1/house1.tscn",
	"motel": "res://map_phase/motel/motel.tscn",
	"church": "res://map_phase/church/church.tscn",
	"store": "res://map_phase/store/store.tscn"
}

# -----------------------------------
# Initialization
# -----------------------------------
func _ready():
	super._ready()
	_setup_buttons()
	_setup_teleport_list()

func _process(_delta):
	if Input.is_action_just_pressed("cheat_menu"):
		toggle()

# -----------------------------------
# Setup
# -----------------------------------
func _setup_buttons() -> void:
	for row in vbox.get_children():
		if row is HBoxContainer and row.get_child_count() >= 2:
			var label = row.get_child(0)
			var button = row.get_child(1)
			if button is Button:
				var text = ""
				if label is Label or label is RichTextLabel:
					text = label.text.to_lower()
				if "god" in text:
					button.pressed.connect(func(): _toggle_god_mode(button))
				elif "hostile" in text:
					button.pressed.connect(func(): _toggle_hostiles(button))
				elif "damage" in text:
					button.pressed.connect(func(): _toggle_damage(button))

func _setup_teleport_list() -> void:
	if not teleport_list or not teleport_list is ItemList:
		return

	teleport_list.clear()
	for key in teleport_map.keys():
		teleport_list.add_item(key.capitalize())

	# Hide by default
	teleport_list.visible = false

	# Handle clicks
	teleport_list.item_clicked.connect(func(index, _pos, _button):
		var location_name = teleport_list.get_item_text(index)
		_teleport_to(location_name)
	)


	# If there's a label above it, allow it to toggle visibility when clicked
	if teleport_label and teleport_label is RichTextLabel:
		# make the label look clickable
		teleport_label.bbcode_enabled = true
		teleport_label.text = "[color=yellow][u]Teleport Locations[/u][/color]"
		teleport_label.gui_input.connect(_on_teleport_label_input)

# -----------------------------------
# Interactions
# -----------------------------------
func _on_teleport_label_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		teleport_list.visible = !teleport_list.visible
		print("Teleport list visible:", teleport_list.visible)

# -----------------------------------
# Button Actions
# -----------------------------------
func _toggle_god_mode(button: Button):
	toggles["god_mode"] = !toggles["god_mode"]
	button.text = "ON" if toggles["god_mode"] else "OFF"
	var player = _get_player()
	if player:
		player.is_invulnerable = toggles["god_mode"]
		if toggles["god_mode"]:
			player.sanity = player.max_sanity
			player.emit_signal("sanity_changed", player.sanity)
		print("God Mode:", toggles["god_mode"])

func _toggle_hostiles(button: Button):
	toggles["hostiles"] = !toggles["hostiles"]
	button.text = "ON" if toggles["hostiles"] else "OFF"
	var gc = _get_game_controller()
	if gc and gc.has_method("set_hostiles_enabled"):
		gc.set_hostiles_enabled(toggles["hostiles"])

func _toggle_damage(button: Button):
	toggles["take_damage"] = !toggles["take_damage"]
	button.text = "ON" if toggles["take_damage"] else "OFF"
	var player = _get_player()
	if player:
		player.is_invulnerable = not toggles["take_damage"]

func _teleport_to(location: String):
	var key = location.strip_edges().to_lower()
	var scene_path = teleport_map.get(key, null)
	if not scene_path:
		print("No scene path mapped for:", location)
		return
	var gc = _get_game_controller()
	if gc:
		gc.change_2d_scene(scene_path)
		close()

# -----------------------------------
# Helpers
# -----------------------------------
func _get_player():
	var gc = _get_game_controller()
	if gc and gc.has_node("Player"):
		return gc.get_node("Player")
	return get_tree().get_first_node_in_group("Player")

func _get_game_controller():
	if Engine.has_singleton("Global"):
		var global = Engine.get_singleton("Global")
		if "game_controller" in global:
			return global.game_controller
	return get_tree().get_root().find_node("GameController", true, false)
