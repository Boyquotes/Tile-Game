### ----------------------------------------------------
### Handles all global input related events
### ----------------------------------------------------
extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# Translate input so its easier to use when i need to refer to a key
const TR = {
	"W" : "Up",
	"A" : "Left",
	"S" : "Down",
	"D" : "Right",
	"E" : "E",
	"Q" : "Q",
	"Z" : "Z",
	"X" : "X",
	"LAlt" : "LAlt",
	"LCtrl" : "LCtrl",
	"ESC" : "ESC",
}

### ----------------------------------------------------
# Global cooldown of pressing keys
### ----------------------------------------------------
const _cdTime = 0.3
var _cd:float = 0
var globalInputCooldown:bool = true


func _physics_process(delta: float) -> void:
	if not globalInputCooldown: 
		_cd -= delta
		if _cd == 0: globalInputCooldown = true
### ----------------------------------------------------
