### ----------------------------------------------------
### Desc
### ----------------------------------------------------

extends Node2D
class_name GameEntity

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var MapPosition:Vector3 setget _set_MapPosition

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _set_MapPosition(posV3:Vector3):
	global_position = LibK.Vectors.vec3_vec2(posV3)
	MapPosition = posV3
