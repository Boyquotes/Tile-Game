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
	isSimulated = true
	scenePath = "res://Resources/Entities/Player/Player.tscn"
