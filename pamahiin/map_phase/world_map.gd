extends Node2D
@onready var cave_marker = $"Marker2D-CaveOut"
@onready var bs = $TransitionLayer/BlackScreen
var player : Player = null
const _ALBULARYO_ENCOUNTER = preload("uid://7vc77grvl72k")
const _WAKWAK_ENCOUNTER = preload("uid://b7tfbpbt3caar")

func _enter_tree() -> void:
	await get_tree().physics_frame
	player  = get_tree().get_first_node_in_group("Player")
	if player:
		player.scale = Vector2(1.0,1.0)
		player.camera.zoom = Vector2(2.0,2.0)
		player.move_speed = 250
		player.sprint_multiplier = 1.8
		player.turnOnLight()
		player.player_resetted.connect(reset_player)
		
func reset_player():
	player.global_position = $"Marker2D-SpawnP".global_position
func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().process_frame
	bs.color.a = 1.0
	player = get_tree().get_first_node_in_group("Player")
	if player:
		if Global.is_player_outside_first_time:
			player.turnOnLight()
			player.is_outside_firsttime = true
			player.is_cutscene_controlled = true
			
			player.setCutsceneAnimationBehavior("Idle", Vector2(1.0,0.0))
			DialogueManager.show_example_dialogue_balloon(_ALBULARYO_ENCOUNTER)
			await DialogueManager.dialogue_ended
			DialogueManager.show_example_dialogue_balloon(_WAKWAK_ENCOUNTER)
			await DialogueManager.dialogue_ended
			player.is_cutscene_controlled = false
			player.is_outside_firsttime = false
			Global.is_player_outside_first_time = false
			
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.CAVE] = cave_marker
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.H1] = $"Marker2D-H1"
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.H2] = $"Marker2D-H2"
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.CHAPEL_EXIT1] = $"Marker2D-Left"
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.CHAPEL_EXIT2] = $"Marker2D-Mid"
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.CHAPEL_EXIT3] = $"Marker2D-Right"
	GameState.dict_TPs[EnumsRef.LOCAL_FROM_TYPE.GARDEN] = $"Marker2D-GardenOut"

		
func getCustomMarker(type :EnumsRef.LOCAL_FROM_TYPE) -> Marker2D:
	return GameState.dict_TPs[type]
	
func gotoCave():
	Global.game_controller.change_2d_scene("uid://dnvq5fs7tu167")

func _on_area_2d_cave_entrance_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		DialogueManager.show_example_dialogue_balloon(load("res://dialogue/CAVE_cave_done.dialogue"))
		


func _on_area_2d_2_body_entered_garden(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Global.game_controller.change_2d_scene("uid://cyqsdqbaspryc")
func show_wakwak() -> void:
	$Wakwak.set_deferred("visible", true)
	
func hide_wakwak() -> void:
	$Wakwak.set_deferred("visible", false)
	
func show_albularyo() -> void:
	$Albularyo.set_deferred("visible", true)
	
func hide_albularyo() -> void:
	$Albularyo.set_deferred("visible", false)
	
func wakwak_sound() -> void:
	$wakwak.play()
	
func fade_blackscreen(from_alpha: float, to_alpha: float, duration: float) -> void:
	if not bs: return
	
	bs.color.a = from_alpha
	var tween = create_tween()
	tween.tween_property(bs, "color:a", to_alpha, duration)
	await tween.finished
	
