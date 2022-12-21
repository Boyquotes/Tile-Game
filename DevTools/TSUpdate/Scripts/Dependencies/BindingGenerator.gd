### ----------------------------------------------------
### Creates tileset script that merges all autotiles (wall autotiles connect)
### ----------------------------------------------------
extends "res://DevTools/TSUpdate/Scripts/Dependencies/ScriptCreator.gd"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

static func generate_merge_script(wallTiles:Array, scriptPath:String, tsPath:String):
	var scriptStr:String = announce("BindingGenerator.gd (TSUpdate)", "TileSet", true)
	
	# Create BINDS variable
	var bindsDict := {}
	for id in wallTiles: bindsDict[id] = wallTiles
	scriptStr += create_variables_str(["const"],["BINDS"],[bindsDict],"BInds dict")
	
	# Create _is_tile_bound function
	scriptStr += "func _is_tile_bound(drawn_id, neighbor_id):\n\tif drawn_id in BINDS:\n\t\treturn neighbor_id in BINDS[drawn_id]\n\treturn false"
	
	# Save script
	LibK.Files.save_res_str(scriptStr, scriptPath)
	Logger.logMS(["[TAB]Binding.gd generated, path: ", scriptPath])
	
	# Add script to TileSet
	var tileSet:TileSet = load(tsPath)
	tileSet.set_script(load(scriptPath))
	Logger.logMS(["[TAB]", LibK.Saving.saveResource(tsPath,tileSet)])
