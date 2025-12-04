extends Node2D

@onready var shownStaticImage:TextureRect = $CanvasLayer/TextureRect
@export var endingType : EnumsRef.EndingType = EnumsRef.EndingType.NEUTRAL
var confessionalImages : Dictionary[StringName, Texture] ={
	"GOOD" : load("uid://c5tdbqqe8tydh"),
	"NEUTRAL1" : load("uid://bsirew7ajb3al"),
	"NEUTRAL2" : load("uid://m53sj50bjoqu"),
	"BAD" : load("uid://ci4twf4c51uyk")
}

func showText(text:String):
	$CanvasLayer/Label.text = text
func play_good_ending():
	DialogueManager.show_example_dialogue_balloon(load("res://dialogue/cutscene/CHURCH_good_ending.dialogue"))
	await DialogueManager.dialogue_ended
	# Fade to black
	var tween := create_tween()
	tween.tween_property(shownStaticImage, "modulate:a", 0.0, 1.5)
	
	# Wait for fade to finish
	await tween.finished
	showText("GOOD ENDING COMPLETED")
func playCreakingNoise():
	var audio: AudioStreamPlayer = $"AudioStreamPlayer3-WoodNoise"
	audio.play(4.44)
	await audio.finished
	shownStaticImage.texture = confessionalImages["NEUTRAL2"]
func play_neutral_ending():
	DialogueManager.show_example_dialogue_balloon(load("res://dialogue/cutscene/CHURCH_neutral_ending.dialogue"))
	await DialogueManager.dialogue_ended
	var tween := create_tween()
	tween.tween_property(shownStaticImage, "modulate:a", 0.0, 1.5)
	
	await tween.finished
	
	showText("NEUTRAL ENDING COMPLETED")
	
func flickerStaticImage():
	$AnimationPlayer.play("flicker_image")
	await $AnimationPlayer.animation_finished
func swapToBad():
	$"AudioStreamPlayer-Laughter".play()
	shownStaticImage.texture = confessionalImages["BAD"]
func showJumpscare():
	$AnimationPlayer.play("flicker_but_not_visible")
	await $AnimationPlayer.animation_finished
	shownStaticImage.texture = load("uid://122f3xs6ln0h")
	$"AudioStreamPlayer-Jumpscare".play()


	
func play_bad_ending():
	DialogueManager.show_example_dialogue_balloon(load("res://dialogue/cutscene/CHURCH_bad_ending.dialogue"))
	await DialogueManager.dialogue_ended
	var tween := create_tween()
	tween.tween_property(shownStaticImage, "modulate:a", 0.0, 1.5)
	
	await tween.finished
	
	showText("BAD ENDING COMPLETED")
	
func _ready() -> void:
	await get_tree().physics_frame
	var player = get_tree().get_first_node_in_group("Player")
	player.queue_free()
	match Global.ending:
		EnumsRef.EndingType.GOOD:
			shownStaticImage.texture = confessionalImages["GOOD"]
			play_good_ending()
		EnumsRef.EndingType.NEUTRAL:
			shownStaticImage.texture = confessionalImages["NEUTRAL1"]
			play_neutral_ending()
		EnumsRef.EndingType.BAD:
			shownStaticImage.texture = confessionalImages["GOOD"]
			play_bad_ending()

func stopSounds():
	$AudioStreamPlayer.stop()
	$AudioStreamPlayer2.stop()
func _on_audio_stream_player_finished() -> void:
	pass
