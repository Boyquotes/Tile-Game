### ----------------------------------------------------
### Desc
### ----------------------------------------------------
extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------
enum ALL_TS {WallFloor, Enviroment} # <- Add manually

enum PROCED_MODES {PineForest}
var currentMode:int = PROCED_MODES.PineForest

# Decides on rarity of a given tile in a given procedural mode
var PROCED_RATE:Dictionary = {}
const PROCED_RATE_SOURCE = {
	PROCED_MODES.PineForest:{
		ALL_TS.WallFloor:{"GrassDark":0.6,"GrassFloor":0.3,"DirtWall":0.1},
		ALL_TS.Enviroment:{"PineTree":0.5,"LeafTree":0.05}
	},
}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# INITIALIZATION #
func initialize(TileMaps) -> bool:
	var TMInfo:Dictionary = {} # TSName: [Tileset, tileNames, tileIDs]
	for tileMap in TileMaps:
		var tileSet:TileSet = tileMap.tile_set
		TMInfo[tileMap.get_name()] = [tileSet,LibK.TS.get_tile_names(tileSet),
		tileSet.get_tiles_ids()]
	
	# Check ALL_TS
	for TSName in ALL_TS:
		if not TSName in TMInfo:
			Logger.logMS(["ALL_TS - TSName: ",TSName,", doesn't exist in available TileMaps. (ProcedGen)"],true)
			return false
	
	# Populate PROCED_RATE dictionary
	for procedMode in PROCED_RATE_SOURCE:
		PROCED_RATE[procedMode] = {}
		for TMName in PROCED_RATE_SOURCE[procedMode]:
			if not TMInfo.has(ALL_TS.keys()[TMName]):
				Logger.logMS(["PROCED_RATE - TSName: ", ALL_TS.keys()[TMName],", doesn't exist in available TileMaps."],true)
				return false
			PROCED_RATE[procedMode][TMName] = LibK.Optimization.range_to_array(PROCED_RATE_SOURCE[procedMode][TMName])
	
	return true
	
