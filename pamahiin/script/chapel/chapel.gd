extends Node2D
# Scene zoom value of 2 is ideal
@onready var spawnPoint : Marker2D = $"Marker2D-SpawnP"
var correct_order = [ "ChapelCandle6-Answer2", "ChapelCandle2-Answer3", 
"ChapelCandle4-Answer4", "ChapelCandle3-Answer5", "ChapelCandle5-Answer6", "ChapelCandle-Answer7"]
var current_step = 0
#@onready var enemy : CharacterBody2D = $EnemyAntilight
@onready var first_face := $CanvasLayer/TextureRect
@onready var second_face := $CanvasLayer/TextureRect2
@onready var third_face := $CanvasLayer/TextureRect3
@onready var enemyPriest : Enemy = $Priest
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var itemTemplateChalice := $"ItemTemplate-chalice"

var player : Player
func fillCup():
	itemTemplateChalice.isCollectible = true
	itemTemplateChalice.item =load("uid://dduywjf84s7ht")
	
func jumpscare_node():
	player.is_cutscene_controlled = true
	first_face.visible =true
	var tween := create_tween()
	$"AudioStreamPlayer2D-JumpscareSounds1".play()
	# 1. First face rises for 2 seconds
	var start_pos = first_face.position
	var target_pos = start_pos + Vector2(0, -428) # rise up 200px
	tween.tween_property(first_face, "position", target_pos, 2.0)

	# Wait until the first tween finishes
	await tween.finished

	# 2. Wait 2 seconds
	await get_tree().create_timer(2.0).timeout
	#await play_face2_and_face3()

	# Optional: add a rumble/sound
	# $JumpscareSound.play()
func play_face2_and_face3():
	# Ensure visible
	second_face.visible = true
	third_face.visible = true

	# --- FACE 2: ZOOM ---
	var t2 = create_tween()
	t2.tween_property(second_face, "scale", Vector2(1.8, 1.8), 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# --- FACE 3: SHAKE ---
	animation_player.play("HeadShake")
	await $AnimationPlayer.animation_finished
	$"AudioStreamPlayer2D-JumpscareSounds1".stop()
	first_face.visible = false
	second_face.visible = false
	third_face.visible = false
	DialogueManager.show_example_dialogue_balloon(load("res://dialogue/cutscene/CHURCH_priest_dialogue.dialogue"))
	player.is_cutscene_controlled = false
	
	enemyPriest.start_funcs()
	
	
func light_setup():
	for child in $LightGroup.get_children():
		var candle := child as ChapelCandle
		candle.interacted.connect(_on_light_pressed.bind(child.name))
		candle.lights_off.connect(reset_sequence_lights)


func disable_endgame_nodes():
	$"Area2D-Confession-Detection/CollisionShape2D".disabled = true
	$"Cutscene_priest/Area2D-TriggerPriestCutscene/CollisionShape2D".disabled = true
	$"Cutscene_priest/Area2D-RitualStart/CollisionShape2D".disabled = true
func enable_endgame_nodes():
	$"Area2D-Confession-Detection/CollisionShape2D".disabled = false
	$"Cutscene_priest/Area2D-TriggerPriestCutscene/CollisionShape2D".disabled = false
	$"Cutscene_priest/Area2D-RitualStart/CollisionShape2D".disabled = false
func _ready():
	await get_tree().physics_frame
	disable_endgame_nodes()
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.CHAPEL_ENTER1] = $"Marker2D-Left1"
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.CHAPEL_ENTER2] = $"Marker2D-SpawnP1"
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.CHAPEL_ENTER3] = $"Marker2D-Right1"
	 
	player = get_tree().get_first_node_in_group("Player")
	if GameState.CHURCH_has_first_enter_church == false:
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/CHURCH_on_entrance.dialogue"))
	first_face.visible = false
	second_face.visible = false
	third_face.visible = false
	second_face.pivot_offset = second_face.size / 2
	$EnemyAntilight.visible = false
	$EnemyAntilight2.visible = false
	$EnemyAntilight3.visible = false
	enemyPriest.stop_funcs()
	$EnemyAntilight.stop_funcs()
	$EnemyAntilight2.stop_funcs()
	$EnemyAntilight3.stop_funcs()
	
	$"ItemTemplate-paper clue".item_inspected.connect(item_inspected_paper)
	$"ItemTemplate-chalice".item_inspected.connect(item_inspected_chalice)
	light_setup()

	
	
	# Animated tiles script
	var node = $TileMap/Animatable_puzzle
	var tween = create_tween().set_loops()  # Repeat forever
	# 1. Flicker opacity (visible → invisible → visible)
	tween.tween_property(node, "modulate:a", 0.25, 1.0)  # fade to 50% in 0.5s
	tween.tween_property(node, "modulate:a", 2.5, 1.0)  # fade back to full in 0.5s
func item_inspected_paper(_item:InvItem):
	GameState.CHURCH_read_paper_for_candle_clue = true
	if not GameState.CHURCH_read_first_chalice_clue:
		return
	start_enemies(_item)
	
func item_inspected_chalice(_item:InvItem):
	GameState.CHURCH_read_first_chalice_clue = true
	if not GameState.CHURCH_read_paper_for_candle_clue:
		return
	start_enemies(_item)
func start_enemies(_item: InvItem):
	$EnemyAntilight.visible = true
	$EnemyAntilight2.visible = true
	$EnemyAntilight3.visible = true
	$EnemyAntilight.start_funcs()
	$EnemyAntilight2.start_funcs()
	$EnemyAntilight3.start_funcs()

func _on_light_pressed(light_name):
	if not GameState.CHURCH_read_first_chalice_clue or not GameState.CHURCH_read_paper_for_candle_clue:
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/church/CHURCH_dumb_dumb_read.dialogue"))
		return

	if light_name == correct_order[current_step]:
		# Correct light
		highlight_correct(light_name)
		current_step += 1

		if current_step >= correct_order.size():
			puzzle_solved()
	else:
		# Wrong light → reset
		reset_sequence()
func reset_sequence_lights():
	print("Lights ran out, resetting puzzle...")
	current_step = 0
	reset_lights_visual()
func reset_sequence():
	print("Wrong light, resetting puzzle...")
	current_step = 0
	reset_lights_visual()

func puzzle_solved():
	print("Puzzle complete!")
	emit_signal("puzzle_completed") # optional
	fillCup()
	$EnemyAntilight.queue_free()
	$EnemyAntilight2.queue_free()
	$EnemyAntilight3.queue_free()
	enable_endgame_nodes()
	DialogueManager.show_example_dialogue_balloon(load("res://dialogue/church/CHURCH_finished_puzzle.dialogue"))

func highlight_correct(light_name):
	for c in $LightGroup.get_children():
		if light_name == c.name:
			var node = c
			node.modulate = Color(0,1,0) # green flash

func reset_lights_visual():
	for c in $LightGroup.get_children():
		c.modulate = Color(1,1,1) # green flash
		var candle := c as ChapelCandle
		candle.play_stop()


func _on_area_2d_body_entered(_body: Node2D) -> void:
	jumpscare_node()
	
func playerWalks_AndPrayRitual():
	await get_tree().physics_frame
	await player.move_towards($"Cutscene_priest/DirectionMarker-standHere")
	player.is_cutscene_controlled = true
	
func getStartRitualDialogue():
	player.is_cutscene_controlled = true
	DialogueManager.show_example_dialogue_balloon(load("res://dialogue/cutscene/CHURCH_set_player_observe_perform_fake_ritual.dialogue"))
	
func _on_area_2d_trigger_priest_cutscen_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player.is_cutscene_controlled = true
		animation_player.play("PriestFalls")
		await animation_player.animation_finished
		$Cutscene_priest.queue_free()
		$LightGroup.queue_free()
		
func _on_area_2d_ritual_start_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player.is_cutscene_controlled = true
		getStartRitualDialogue()


func _on_area_2d_confession_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene("uid://cs6dmviesqyfy")


func _on_area_2d_left_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_custom("uid://cyc8laq2oakj0", EnumsRef.LOCAL_FROM_TYPE.CHAPEL_EXIT1)



func _on_area_2d_2_mid_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_custom("uid://cyc8laq2oakj0", EnumsRef.LOCAL_FROM_TYPE.CHAPEL_EXIT2)


func _on_area_2d_3_right_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene_custom("uid://cyc8laq2oakj0", EnumsRef.LOCAL_FROM_TYPE.CHAPEL_EXIT3)
		
func getCustomMarker(type :EnumsRef.LOCAL_FROM_TYPE) -> Marker2D:
	print(type)
	return GameState.dict_TPs[type]
