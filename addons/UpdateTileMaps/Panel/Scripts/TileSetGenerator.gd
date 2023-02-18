### ----------------------------------------------------
### Helps with automatic tileset creation based on materials in DATA.gd singleton
### Short description:
### 	Every tile consists of Outline.png and BG.png
### 	BGs color is shifted to match material color
### 	BG is put at the back and Outline on top
### 	Resulting texture is added as a tile
### ----------------------------------------------------

extends Script

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# For autotile, sets premade bitmask template on a tileset
const BITMASK_FLAGS:Array = [ Vector2( 0, 0 ), 432, Vector2( 0, 1 ), 438, Vector2( 0, 2 ), 54, Vector2( 0, 3 ), 48, Vector2( 0, 4 ), 248, Vector2( 0, 5 ), 59, Vector2( 1, 0 ), 504, Vector2( 1, 1 ), 511, Vector2( 1, 2 ), 63, Vector2( 1, 3 ), 56, Vector2( 1, 4 ), 440, Vector2( 1, 5 ), 62, Vector2( 2, 0 ), 216, Vector2( 2, 1 ), 219, Vector2( 2, 2 ), 27, Vector2( 2, 3 ), 24, Vector2( 2, 4 ), 182, Vector2( 2, 5 ), 434, Vector2( 3, 0 ), 144, Vector2( 3, 1 ), 146, Vector2( 3, 2 ), 18, Vector2( 3, 3 ), 16, Vector2( 3, 4 ), 155, Vector2( 3, 5 ), 218, Vector2( 4, 0 ), 255, Vector2( 4, 1 ), 507, Vector2( 4, 2 ), 506, Vector2( 4, 3 ), 191, Vector2( 4, 4 ), 176, Vector2( 4, 5 ), 50, Vector2( 5, 0 ), 447, Vector2( 5, 1 ), 510, Vector2( 5, 2 ), 251, Vector2( 5, 3 ), 446, Vector2( 5, 4 ), 152, Vector2( 5, 5 ), 26, Vector2( 6, 1 ), 254, Vector2( 6, 2 ), 442, Vector2( 6, 3 ), 190, Vector2( 6, 4 ), 184, Vector2( 6, 5 ), 178, Vector2( 7, 0 ), 186, Vector2( 7, 1 ), 443, Vector2( 7, 2 ), 250, Vector2( 7, 3 ), 187, Vector2( 7, 4 ), 58, Vector2( 7, 5 ), 154 ]

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


# Function outputs array of data regarding a TileMap
# Directory structure:
# tileMapsDir/TileMapName/TypeOfTile/SetName/[BG.png and Outline.png]
# TMdata = { TMName:{Autotile:{setName:setDir}, Single:{setName:setDir}} }
static func get_TMdata(tileMapsDir:String, logFunc:FuncRef) -> Dictionary:
	var TMdata:Dictionary = {} 	
	if not LibK.Files.dir_exist(tileMapsDir):
		logFunc.call_func(["tileMapsDir folder: ", tileMapsDir, ", doesn't exist."], true)
		return {}
	
	for packed in LibK.Files.get_file_list_at_dir(tileMapsDir):
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
static func create_tile_data(dir:String) -> Dictionary:
	var data:Dictionary = {}
	for packed in LibK.Files.get_file_list_at_dir(dir):
		data[packed[1]] = packed[0]
	return data

# Returns all TileSets in Resource directory
# TileSets[fileName] = TileSet (loaded)
static func get_TileSets(tileMapsDir:String, logFunc:FuncRef) -> Dictionary:
	var TileSets:Dictionary = {}
	if not LibK.Files.dir_exist(tileMapsDir):
		logFunc.call_func(["tileMapsDir folder: ", tileMapsDir, ", doesn't exist."], true)
		return {}
	
	for packed in LibK.Files.get_file_list_at_dir(tileMapsDir):
		var filePath:String = packed[0]
		var fileName:String = packed[1]
		TileSets[fileName] = load(filePath + "/TileSet.tres")
	
	return TileSets

# Adds autotiles according to types declared in DATA
# data = {Autotile:{setName:setDir}, Single:{setName:setDir}}
static func add_tile_types(tileSet:TileSet, data:Dictionary, logFunc:FuncRef) -> TileSet:
	if not DATA.MATERIALS.CHECK_TYPES():
		logFunc.call_func(["[b]update terminated[/b]"], true)
		return tileSet
	
	logFunc.call_func(["\t[b]< Adding tile types[/b]"], false)
	tileSet = _add_tile_type(tileSet, data, "Autotile", logFunc)
	tileSet = _add_tile_type(tileSet, data, "Single", logFunc)
	logFunc.call_func(["\t[b]> Adding tile types[/b]"], false)
	
	logFunc.call_func(["\t[b]< Removing outdated tiles[/b]"], false)
	tileSet = _remove_old_tiles(tileSet, logFunc)
	logFunc.call_func(["\t[b]> Removing outdated tiles[/b]"], false)
	
	return tileSet

# Adds all materials to TileSet
static func _add_tile_type(tileSet:TileSet, data:Dictionary, tileType:String, logFunc:FuncRef) -> TileSet:
	if not data.has(tileType):
		logFunc.call_func(["\tTileType ",tileType,", doesnt exist in data"], false)
		return tileSet
	
	for setName in data[tileType]:
		var textureBGPath:String = data[tileType][setName]+"/BG.png"
		if not LibK.Files.file_exist(textureBGPath):
			logFunc.call_func(["\tFile doesnt exist (textureBGPath): ",textureBGPath], true)
			continue
		
		var textureOutlinePath:String = data[tileType][setName]+"/Outline.png"
		if not LibK.Files.file_exist(textureOutlinePath):
			logFunc.call_func(["\tFile doesnt exist (textureOutlinePath): ",textureOutlinePath], true)
			continue
		
		var textureBG:Texture = load(textureBGPath)
		var textureOutline:Texture = load(textureOutlinePath)
		
		for M_TYPE in DATA.MATERIALS.TYPES.values():
			var M_COLOR:Color = DATA.MATERIALS.DB[M_TYPE]["Color"]
			var texture:Texture = LibK.Img.blend_textures(textureBG, textureOutline, M_COLOR, 0.5)
			var tileName:String = DATA.MATERIALS.TYPES.keys()[M_TYPE] + setName + DATA.MATERIALS.GENERATED_TAG
			var tileMode:int = TileSet.SINGLE_TILE
			if tileType == "Autotile": tileMode = TileSet.AUTO_TILE
			
			tileSet = LibK.TS._add_tile(tileSet, tileName, texture, tileMode, BITMASK_FLAGS)
			logFunc.call_func(["\tAdded tile: ",tileName,", to ",setName], false)
	
	return tileSet

# Removes all non existent material tiles that were previously generated
static func _remove_old_tiles(tileSet:TileSet, logFunc:FuncRef) -> TileSet:
	var tileNames:Array = LibK.TS.get_tile_names(tileSet)
	var tileIDs:Array = tileSet.get_tiles_ids()
	var tilesToDelete:Array = []
	for index in range(tileIDs.size()):
		var tileName:String = tileNames[index]
		var tileID:int = tileIDs[index]

		# Only check for generated tiles
		if not DATA.MATERIALS.GENERATED_TAG in tileName:
			continue
		
		# Delete outdated tiles
		var isIn:bool = false
		for materialName in DATA.MATERIALS.TYPES.keys():
			if materialName in tileName:
				isIn = true
		
		if not isIn:
			tilesToDelete.append(tileID)
	for tileID in tilesToDelete:
		var rmTN:String = tileSet.tile_get_name(tileID)
		tileSet.remove_tile(tileID)
		logFunc.call_func(["\tRemoved outdated tile: ", rmTN], false)
	return tileSet