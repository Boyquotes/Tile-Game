### ----------------------------------------------------
### Generates script that merges walls together
### ----------------------------------------------------

extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

static func generate_TILES_script(TileSets:Dictionary, scriptPath:String, logFunc:FuncRef) -> bool:
	logFunc.call_func(["Creating TILES.gd singleton at: ",scriptPath], false)
	var scriptStr:String = LibK.ScriptGen.announce("ScriptsGenerator.gd (UpdateTimeMaps)", "Node")

	scriptStr += LibK.ScriptGen.get_marker_str("TILESET TILE NAMES",false)
	for TSName in TileSets:
		var tileSet = TileSets[TSName]
		scriptStr += LibK.ScriptGen.get_enum_str_ordered(TSName.to_upper(), LibK.TS.get_tile_names(tileSet), tileSet.get_tiles_ids())
		scriptStr += "\n"
	scriptStr += LibK.ScriptGen.get_marker_str("TILESET TILE NAMES",true)
	
	if(LibK.Files.save_res_str(scriptStr, scriptPath) != OK):
		logFunc.call_func("logMessage", ["Failed to save TILES.gd singleton."], true)
		return false
	logFunc.call_func(["Finished Creating TILES.gd singleton."], false)
	return true

# Generates script that binds autotiles in a set together
static func generate_binding_script(wallTiles:Array, scriptPath:String, tsPath:String, logFunc:FuncRef) -> bool:
	var scriptStr:String = LibK.ScriptGen.announce("ScriptsGenerator.gd (addons/UpdateTileMaps)", "TileSet", true)
	
	var bindsDict := {}
	for id in wallTiles: bindsDict[id] = wallTiles
	scriptStr += LibK.ScriptGen.create_variables_str(["const"],["BINDS"],[bindsDict],"Binds dict")
	
	# Create _is_tile_bound function
	scriptStr += "func _is_tile_bound(drawn_id, neighbor_id):\n\tif drawn_id in BINDS:\n\t\treturn neighbor_id in BINDS[drawn_id]\n\treturn false"
	
	if(LibK.Files.save_res_str(scriptStr, scriptPath) != OK):
		logFunc.call_func(["\tFailed to generate Binding.gd, path: ", scriptPath], true)
		return false
	logFunc.call_func(["\tBinding.gd generated, path: ", scriptPath], false)
	
	# Add script to TileSet
	var tileSet:TileSet = load(tsPath)
	tileSet.set_script(load(scriptPath))
	var result := ResourceSaver.save(tsPath,tileSet)
	if(result != OK):
		logFunc.call_func(["Failed to create binding script: ", scriptPath, " ", result], true)
		return false
	logFunc.call_func(["Created binding script: ", scriptPath], false)
	return true
