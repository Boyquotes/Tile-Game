### ----------------------------------------------------
### Base class for player
### ----------------------------------------------------
extends EntityBase

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

func _ready() -> void:
	initialize()


func initialize():
	Init.isSimulated = true
	Init.scenePath = "res://Resources/Entities/Player/Player.tscn"
