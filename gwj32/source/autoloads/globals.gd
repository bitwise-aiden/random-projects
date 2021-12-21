extends Node


# Time globals

# Current rate of time passing.
#	1.0 is default
#	< 1.0 is slowed down
#	> 1.0 is speed up
var time_modifier: float = 1.0


# Instance globals
var mini_map = null
var player = null


# Lifecycle methods
func _ready() -> void:
	randomize()
