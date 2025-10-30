class_name GameController
extends Node

@export var gui: Control
@export var world_2d: Node2D  

var player: CharacterBody2D
var curr_2d_scene: Node = null
var curr_gui_scene: Node = null

# --- Dynamic Menus ---
var exit_menu: Control
var cheat_menu: Control
var inventory_menu: Control

signal hostiles_toggled(enabled: bool)

# --- Preloads for Dynamic Instancing ---
const ExitMenuScene := preload("res://utils/menus/exit_menu.tscn")
const CheatMenuScene := preload("res://utils/menus/cheats/cheat_menu.tscn")
const InventoryMenuScene := preload("res://utils/menus/inventory_menu.tscn")

# ---------------------------------------
# Initialization
# ---------------------------------------
func _ready() -> void:
	Global.game_controller = self

	await get_tree().process_frame
	player = get_node_or_null("World2D/Player")

	if player:
		if not player.is_in_group("Player"):
			player.add_to_group("Player")
	else:
		push_warning("⚠️ Player not found in GameController at startup.")

	change_2d_scene("res://dev/paul's do not touch/test_church.tscn")
	add_to_group("game_controller")

	# 🆕 Dynamically add menus
	_create_exit_menu()
	_create_cheat_menu()
	_create_inventory_menu()

# ---------------------------------------
# Menu Creation Functions
# ---------------------------------------
func _create_exit_menu() -> void:
	exit_menu = ExitMenuScene.instantiate()
	gui.add_child(exit_menu)

	# Connect signals
	exit_menu.resumed.connect(_on_game_resumed)
	exit_menu.main_menu.connect(_on_main_menu_pressed)
	exit_menu.quit_game.connect(_on_quit_game_pressed)

	exit_menu.visible = false
	print("✅ Exit Menu loaded dynamically.")

func _create_cheat_menu() -> void:
	cheat_menu = CheatMenuScene.instantiate()
	gui.add_child(cheat_menu)
	cheat_menu.visible = false
	print("✅ Cheat Menu loaded dynamically.")

func _create_inventory_menu() -> void:
	inventory_menu = InventoryMenuScene.instantiate()
	gui.add_child(inventory_menu)
	inventory_menu.visible = false
	print("✅ Inventory Menu placeholder loaded (hidden).")

# ---------------------------------------
# Exit Menu Signal Callbacks
# ---------------------------------------
func _on_game_resumed() -> void:
	print("▶ Game resumed.")
	get_tree().paused = false

func _on_main_menu_pressed() -> void:
	print("🏠 Returning to main menu...")
	get_tree().paused = false
	# get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_game_pressed() -> void:
	print("❌ Quitting game...")
	get_tree().quit()

# ---------------------------------------
# Scene Management
# ---------------------------------------
func change_2d_scene(new_scene: String, _load_state: EnumsRef.SceneLoadState = EnumsRef.SceneLoadState.DELETE) -> void:
	if curr_2d_scene:
		match _load_state:
			EnumsRef.SceneLoadState.DELETE:
				curr_2d_scene.queue_free()
			EnumsRef.SceneLoadState.HIDE:
				curr_2d_scene.visible = false
			EnumsRef.SceneLoadState.REMOVE_HIDDEN:
				gui.remove_child(curr_2d_scene)

	var new_scene_instance = load(new_scene).instantiate()
	world_2d.add_child(new_scene_instance)
	curr_2d_scene = new_scene_instance

	if player:
		var spawn_marker = new_scene_instance.get_node_or_null("Marker2D-SpawnP")
		if spawn_marker:
			player.global_position = spawn_marker.global_position
			var camera: Camera2D = player.get_node("Camera2D")
			camera.reset_smoothing()
		else:
			push_warning("No Marker2D-SpawnP found in new scene.")
	else:
		push_error("Player not initialized in GameController.")

# ---------------------------------------
# Utility Functions
# ---------------------------------------
func set_hostiles_enabled(enabled: bool) -> void:
	print("Hostiles enabled:", enabled)
	for node in world_2d.get_children():
		if node.is_in_group("Enemies"):
			node.process_mode = Node.PROCESS_MODE_ALWAYS if enabled else Node.PROCESS_MODE_DISABLED
	emit_signal("hostiles_toggled", enabled)
