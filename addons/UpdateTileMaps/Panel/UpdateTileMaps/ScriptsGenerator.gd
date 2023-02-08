### ----------------------------------------------------
### Desc
### ----------------------------------------------------

tool
extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

signal logMessage

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func generate_TILES_script(TileSets:Dictionary, scriptPath:String):
	emit_signal("logMessage", ["Creating TILES.gd singleton at: ",scriptPath], false)
	var scriptStr:String = LibK.ScriptGen.announce("ScriptsGenerator.gd (UpdateTimeMaps)", "Node")
	
	scriptStr += LibK.ScriptGen.get_marker_str("TILESET TILE NAMES",false)
	for TSName in TileSets:
		var tileSet = TileSets[TSName]
		scriptStr += LibK.ScriptGen.get_enum_str_ordered(TSName.to_upper(), LibK.TS.get_tile_names(tileSet), tileSet.get_tiles_ids())
		scriptStr += "\n"
	scriptStr += LibK.ScriptGen.get_marker_str("TILESET TILE NAMES",true)
	
	# Save script
	LibK.Files.save_res_str(scriptStr, scriptPath)
	emit_signal("logMessage", ["Finished Creating TILES.gd singleton."], false)


func generate_binding_script(wallTiles:Array, scriptPath:String, tsPath:String):
	var scriptStr:String = LibK.ScriptGen.announce("ScriptsGenerator.gd (UpdateTimeMaps)", "TileSet", true)
	
	# Create BINDS variable
	var bindsDict := {}
	for id in wallTiles: bindsDict[id] = wallTiles
	scriptStr += LibK.ScriptGen.create_variables_str(["const"],["BINDS"],[bindsDict],"BInds dict")
	
	# Create _is_tile_bound function
	scriptStr += "func _is_tile_bound(drawn_id, neighbor_id):\n\tif drawn_id in BINDS:\n\t\treturn neighbor_id in BINDS[drawn_id]\n\treturn false"
	
	# Save script
	LibK.Files.save_res_str(scriptStr, scriptPath)
	emit_signal("logMessage", ["\tBinding.gd generated, path: ", scriptPath], false)
	
	# Add script to TileSet
	var tileSet:TileSet = load(tsPath)
	tileSet.set_script(load(scriptPath))
	emit_signal("logMessage", ["\t", LibK.Saving.saveResource(tsPath,tileSet)], false)
