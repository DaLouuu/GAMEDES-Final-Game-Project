extends Node

# name under Globals: Global
var game_controller: GameController = null
var artifactCount = 0
var rng : RandomNumberGenerator
var ending : EnumsRef.EndingType  = EnumsRef.EndingType.BAD
var is_player_outside_first_time = true
