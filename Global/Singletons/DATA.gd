### ----------------------------------------------------
### Singleton for storing game data
### Stores general data like seed for map gen, chunk size ect
### All data modules are preloaded as scripts
### ----------------------------------------------------
tool
extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const TILEMAPS_DIR:String = "res://Resources/TileMaps/"
const SAVE_FLODER_PATH:String = "res://Resources/SaveData/SavedMaps/"

const GENERATED_TAG:String = "%GEN%"

const Map:Script = preload("res://Global/Singletons/DATA resources/Map.gd")
const Materials:Script = preload("res://Global/Singletons/DATA resources/Materials.gd")


### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------
func _init() -> void:
	Materials.CHECK_TYPES()
