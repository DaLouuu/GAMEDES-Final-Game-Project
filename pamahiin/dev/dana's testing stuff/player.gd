extends Node2D

var inventory = ["Rosary", "Salt", "Candle"]
var sanity = 100
var max_sanity = 100
var is_invulnerable = false

signal sanity_changed(new_sanity)
