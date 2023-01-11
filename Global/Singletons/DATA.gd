### ----------------------------------------------------
### Singleton for storing game data
### Stores general data like seed for map gen, chunk size ect
### All data modules are preloaded as scripts
### ----------------------------------------------------

tool
extends Node

### ----------------------------------------------------
# CLASSES
### ----------------------------------------------------


# Stores data regarding all meterial types
# Material types define color and properties of objects and tiles in the game
# Colors: https://www.rapidtables.com/web/color/RGB_Color.html
class MATERIALS: 
	const GENERATED_TAG:String = "_GEN_"
	enum TYPES {WoodenPlank,Stone,Dirt,Grass,DarkGrass}
	const DB:Dictionary = {
		TYPES.WoodenPlank:{"Color":Color('#816109')},
		TYPES.Stone: 	  {"Color":Color('#708090')},
		TYPES.Dirt:  	  {"Color":Color('#483D8B')},
		TYPES.Grass: 	  {"Color":Color('#228B22')},
		TYPES.DarkGrass:  {"Color":Color('#006400')},
	}

	static func CHECK_TYPES() -> bool:
		var isOK:bool = true
		for keyVal in TYPES.values():
			if not keyVal in DB:
				isOK = false
				Logger.logErr(["DATA.MATERIALS - ", TYPES.keys()[keyVal], " missing in DB"], get_stack())
		
		return isOK


# Stores data about what key translates to what action in input map
# Hardcode a key input when needed
class INPUT:
	const MAP = {
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
		"F" : "F",
		"G" : "G",
		"=" : "Equal",
		"-" : "Minus",
	}


# Stores data regardning map, TileMaps ect
class MAP:
	const TILEMAPS_DIR:String = "res://Resources/TileMaps/"
	const SIM_RANGE = 1   # How far (chunks) world will generate 
	const CHUNK_SIZE = 8  # Keep it 2^x (min 8,max 32 - for both performance and drawing reasons)
	const BASE_SCALE = 16 # Pixel size of tiles

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _ready() -> void:
	if get_tree().get_root().has_node("Logger"):
		Logger.logMS(["Materials correction check: ", MATERIALS.CHECK_TYPES()])
