### ----------------------------------------------------
### Setup script for TSUpdate
### ----------------------------------------------------

tool
extends "res://addons/UpdateTileMaps/Panel/UpdateTileMaps/TileSetGenerator.gd"

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# For autotile, sets premade bitmask template on a tileset
const BITMASK_FLAGS:Array = [ Vector2( 0, 0 ), 432, Vector2( 0, 1 ), 438, Vector2( 0, 2 ), 54, Vector2( 0, 3 ), 48, Vector2( 0, 4 ), 248, Vector2( 0, 5 ), 59, Vector2( 1, 0 ), 504, Vector2( 1, 1 ), 511, Vector2( 1, 2 ), 63, Vector2( 1, 3 ), 56, Vector2( 1, 4 ), 440, Vector2( 1, 5 ), 62, Vector2( 2, 0 ), 216, Vector2( 2, 1 ), 219, Vector2( 2, 2 ), 27, Vector2( 2, 3 ), 24, Vector2( 2, 4 ), 182, Vector2( 2, 5 ), 434, Vector2( 3, 0 ), 144, Vector2( 3, 1 ), 146, Vector2( 3, 2 ), 18, Vector2( 3, 3 ), 16, Vector2( 3, 4 ), 155, Vector2( 3, 5 ), 218, Vector2( 4, 0 ), 255, Vector2( 4, 1 ), 507, Vector2( 4, 2 ), 506, Vector2( 4, 3 ), 191, Vector2( 4, 4 ), 176, Vector2( 4, 5 ), 50, Vector2( 5, 0 ), 447, Vector2( 5, 1 ), 510, Vector2( 5, 2 ), 251, Vector2( 5, 3 ), 446, Vector2( 5, 4 ), 152, Vector2( 5, 5 ), 26, Vector2( 6, 1 ), 254, Vector2( 6, 2 ), 442, Vector2( 6, 3 ), 190, Vector2( 6, 4 ), 184, Vector2( 6, 5 ), 178, Vector2( 7, 0 ), 186, Vector2( 7, 1 ), 443, Vector2( 7, 2 ), 250, Vector2( 7, 3 ), 187, Vector2( 7, 4 ), 58, Vector2( 7, 5 ), 154 ]

export (Vector2) var TILE_SIZE        = Vector2(DATA.TILEMAPS.BASE_SCALE, DATA.TILEMAPS.BASE_SCALE)
export (String)  var TILEMAPS_DIR     = DATA.TILEMAPS.TILEMAPS_DIR
export (String)  var TILES_SCRIPT_DIR = "res://Global/Singletons/TILES.gd"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### ----------------------------------------------------
# Getting TileMap data
### ----------------------------------------------------

# Function outputs array of data regarding a TileMap
# Directory structure:
# TILEMAPS_DIR/TileMapName/TypeOfTile/SetName/[BG.png and Outline.png]
# TMdata = { TMName:{Autotile:data, Single:data} }
# data = {setName:setDir}
func get_TMdata() -> Dictionary:
	var TMdata:Dictionary = {} 	
	if not LibK.Files.dir_exist(TILEMAPS_DIR):
		emit_signal("logMessage", ["TILEMAPS_DIR folder: ", TILEMAPS_DIR, ", doesn't exist."], true)
		return {}
	
	for packed in LibK.Files.get_file_list_at_dir(TILEMAPS_DIR):
		var filePath:String = packed[0]
		var fileName:String = packed[1]
		TMdata[fileName] = {}
		
		# Check if any autotiles exist
		var autotileDir = filePath + "/Autotile"
		if LibK.Files.dir_exist(autotileDir):
			TMdata[fileName]["Autotile"] = create_tile_data(autotileDir)
		
		# Check if any single tiles exist
		var singleDir = filePath + "/Single"
		if LibK.Files.dir_exist(singleDir):
			TMdata[fileName]["Single"] = create_tile_data(singleDir)
		
	return TMdata


# Creates dict of directories inside of a folder 
# {dirName : directory}
func create_tile_data(dir:String) -> Dictionary:
	var data:Dictionary = {}
	for packed in LibK.Files.get_file_list_at_dir(dir):
		data[packed[1]] = packed[0]
	return data
### ----------------------------------------------------


### ----------------------------------------------------
# Getting TileSet data
### ----------------------------------------------------

# Returns all TileSets in Resource directory
# TileSets[fileName] = TileSet (loaded)
func get_TileSets() -> Dictionary:
	var TileSets:Dictionary = {}
	
	if not LibK.Files.dir_exist(TILEMAPS_DIR):
		emit_signal("logMessage", ["TILEMAPS_DIR folder: ", TILEMAPS_DIR, ", doesn't exist."], true)
		return {}
	
	for packed in LibK.Files.get_file_list_at_dir(TILEMAPS_DIR):
		var filePath:String = packed[0]
		var fileName:String = packed[1]
		TileSets[fileName] = load(filePath + "/TileSet.tres")
	
	return TileSets
### ----------------------------------------------------
