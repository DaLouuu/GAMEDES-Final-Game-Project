extends Node2D

var dict_TPs : Dictionary[EnumsRef.LOCAL_FROM_TYPE, Marker2D]
var HOUSE_has_artifact_rosary_said_in_dialogue = false
var HOUSE_seen_key_but_did_not_pickup = false
var HOUSE_ARTIFACT_has_artifact_rosary = false
var HOUSE_has_read_clue = false
var HOUSE_has_asked_about_rosary = false # set this to true to enter house
var HOUSE_has_gotten_house_key = false
var HOUSE_has_chest_opened = false
var HOUSE_finished_puzzle = false
var HOUSE_has_failed_puzzle_first_time = false
var HOUSE_has_seen_white_lady = false
var HOUSE_has_met_ghost_girl = false  # set this to true to enter house
var HOUSE_read_first_item_puzzle = false
