### ----------------------------------------------------
### Generates singleton that has quick access to all generated tiles in enums
### ----------------------------------------------------
extends "res://DevTools/TSUpdate/Scripts/Dependencies/ScriptCreator.gd"

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const TILES_SCRIPT_DIR = "res://Global/Singletons/TILES.gd"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

static func generate_TILES_script(TileSets:Dictionary):
	Logger.logMS(["Creating TILES.gd singleton at: ",TILES_SCRIPT_DIR])
	var scriptStr:String = announce("TILESGenerator.gd (TSUpdate)", "Node")
	
	scriptStr += get_marker_str("TILESET TILE NAMES",false)
	for TSName in TileSets:
		var tileSet = TileSets[TSName]
		scriptStr += get_enum_str_ordered(TSName.to_upper(), LibK.TS.get_tile_names(tileSet), tileSet.get_tiles_ids())
		scriptStr += "\n"
	scriptStr += get_marker_str("TILESET TILE NAMES",true)
	
	# Save script
	LibK.Files.save_res_str(scriptStr, TILES_SCRIPT_DIR)
	Logger.logMS(["Finished Creating TILES.gd singleton."])
		
