extends MenuBase

@onready var vbox = $Panel/ScrollContainer/PanelContainer/VBoxContainer
@onready var teleport_label = vbox.get_node_or_null("RichTextLabel") # the label above ItemList
@onready var teleport_list = vbox.get_node_or_null("ItemList")

var toggles := {
	"god_mode": false,
	"hostiles": true,
	"take_damage": true
}

# Example teleport destinations (temporary)
var teleport_map := {
	"test": "res://dev/dana's_testing_stuff/Player.tscn",
	# add the other phases here
}


# Track the initial state of toggles for comparison
var _initial_toggles := toggles.duplicate(true)

# Reference for the bottom "Apply" button
var apply_button: Button

# INITIALIZATION
func _ready():
	get_tree().paused = false
	super._ready()
	_setup_buttons()
	_setup_teleport_list()

func _process(_delta):
	if Input.is_action_just_pressed("cheat_menu"):
		toggle()

# SETUP
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
					button.pressed.connect(func(): _on_toggle_changed("god_mode", button))
				elif "hostile" in text:
					button.pressed.connect(func(): _on_toggle_changed("hostiles", button))
				elif "damage" in text:
					button.pressed.connect(func(): _on_toggle_changed("take_damage", button))

	# Handle bottom Apply button under the last ScrollContainer
	var bottom_scroll = vbox.get_node_or_null("ScrollContainer")
	if bottom_scroll:
		apply_button = bottom_scroll.get_node_or_null("Button")
		if apply_button:
			apply_button.text = "APPLY"
			apply_button.disabled = true  # disabled until a change is made
			apply_button.pressed.connect(_apply_cheats)

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

# Called when any of the three toggles are changed
func _on_toggle_changed(key: String, button: Button):
	toggles[key] = !toggles[key]
	button.text = "ON" if toggles[key] else "OFF"
	_check_toggle_changes()

# INTERACTIONS
func _on_teleport_label_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		teleport_list.visible = !teleport_list.visible
		print("Teleport list visible:", teleport_list.visible)

# BUTTON ACTIONS
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

	if not ResourceLoader.exists(scene_path):
		print("⚠️ Teleport target does not exist yet:", scene_path)
		return

	var gc = _get_game_controller()
	if gc:
		print("Teleporting to:", scene_path)
		gc.change_2d_scene(scene_path)
		close()
	else:
		print("⚠️ GameController not found; cannot teleport.")

func _check_toggle_changes() -> void:
	if not apply_button:
		return
	# Compare current toggles vs initial snapshot
	var changed := false
	for k in toggles.keys():
		if toggles[k] != _initial_toggles[k]:
			changed = true
			break
	apply_button.disabled = not changed

func _apply_cheats() -> void:
	print("--- Applying cheat menu settings ---")
	var player = _get_player()
	var gc = _get_game_controller()

	# Apply all toggles
	if player:
		player.is_invulnerable = toggles["god_mode"] or not toggles["take_damage"]
		if toggles["god_mode"]:
			player.sanity = player.max_sanity
			player.emit_signal("sanity_changed", player.sanity)

	if gc and gc.has_method("set_hostiles_enabled"):
		gc.set_hostiles_enabled(toggles["hostiles"])

	print("God Mode:", toggles["god_mode"])
	print("Hostiles Enabled:", toggles["hostiles"])
	print("Take Damage:", toggles["take_damage"])
	print("--- Cheats applied ---")

	# Save new state as baseline
	_initial_toggles = toggles.duplicate(true)
	apply_button.disabled = true

	# Visual + Text Feedback
	if apply_button:
		var old_text = apply_button.text
		apply_button.text = "CHANGES APPLIED!"
		apply_button.modulate = Color(0.7, 1, 0.7, 1)  # light green
		await get_tree().create_timer(0.8).timeout
		apply_button.text = old_text
		apply_button.modulate = Color(1, 1, 1, 1)

	# Smooth panel flash (optional aesthetic)
	$Panel.modulate = Color(0.85, 1, 0.85, 1)
	await get_tree().create_timer(0.15).timeout
	$Panel.modulate = Color(1, 1, 1, 1)

	close()

# HELPERS
func _get_player():
	var gc = _get_game_controller()
	if gc and gc.has_node("Player"):
		return gc.get_node("Player")
	return get_tree().get_first_node_in_group("Player")

func _get_game_controller():
	# First: check Global singleton
	if Engine.has_singleton("Global"):
		var global = Engine.get_singleton("Global")
		if "game_controller" in global and global.game_controller:
			return global.game_controller

	# Second: check group (lowercase, matches add_to_group)
	var gc = get_tree().get_first_node_in_group("game_controller")
	if gc:
		return gc

	push_error("⚠️ GameController not found in scene tree!")
	return null
