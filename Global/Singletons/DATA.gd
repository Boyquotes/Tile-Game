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

const Materials:Script = preload("res://Global/Singletons/DATA resources/Materials.gd")
const TILEMAPS_DIR:String = "res://Resources/TileMaps/"
const GENERATED_TAG:String = "_GEN_"

### ----------------------------------------------------
# Map vars
### ----------------------------------------------------
const CHUNK_SIZE = 8  # Keep it 2^x (min 8,max 32 - for both performance and drawing reasons)
const BASE_SCALE = 16 # Pixel size of tiles
### ----------------------------------------------------

var SAVE_FOLDER_PATH:String = "res://Resources/SaveData/SavedMaps/"

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

func _init() -> void:
	var _result:bool = Materials.CHECK_TYPES()
