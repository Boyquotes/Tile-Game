### ----------------------------------------------------
### Script automatically updates all TileMaps
### Requires predefined directory structure in order to work:
### TILEMAPS_DIR/TileMapName/TypeOfTile/SetName/[BG.png and Outline.png]
### ----------------------------------------------------

extends Script

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const TILE_SIZE = Vector2(DATA.TILEMAPS.BASE_SCALE, DATA.TILEMAPS.BASE_SCALE)
const TILEMAPS_DIR = DATA.TILEMAPS.TILEMAPS_DIR
const TILES_SCRIPT_DIR = "res://Global/Singletons/TILES.gd"

const SCRIPTS_GEN = preload("res://addons/UpdateTileMaps/Panel/Scripts/ScriptsGenerator.gd")
const TILESET_GEN = preload("res://addons/UpdateTileMaps/Panel/Scripts/TileSetGenerator.gd")

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


static func start_script(logFunc:FuncRef) -> void:
	_update_TileSets(logFunc)
	_update_TileMaps(logFunc)
	SCRIPTS_GEN.generate_TILES_script(TILESET_GEN.get_TileSets(TILEMAPS_DIR, logFunc), TILES_SCRIPT_DIR, logFunc)

static func _update_TileSets(logFunc:FuncRef) -> void:
	var TMData:Dictionary = TILESET_GEN.get_TMdata(TILEMAPS_DIR, logFunc)
	for TMName in TMData: 
		if(not _update_TileSet(TMName, TMData, logFunc)):
			logFunc.call_func(["Failed to update TileSet: ", TMName], true)

# Creates a tileset, fills it with generated tiles
static func _update_TileSet(TMName:String, TMData:Dictionary, logFunc:FuncRef) -> bool:
	var tileSetDir = TILEMAPS_DIR + TMName + "/TileSet.tres"
	
	if not LibK.Files.file_exist(tileSetDir):
		var result := ResourceSaver.save(tileSetDir, TileSet.new())
		if(result != OK):
			logFunc.call_func(["Failed to create a new TileSet: ", tileSetDir], true)
			return false
		logFunc.call_func(["Created new TileSet: ", tileSetDir], false)
	
	var tileSet:TileSet = load(tileSetDir)
	logFunc.call_func(["[b]Updating TileSet: [/b]", TMName], false)
	
	# Update tiles of material types (autotile and single tile excluding universal)
	tileSet = TILESET_GEN.add_tile_types(tileSet, TMData[TMName], logFunc)
	
	var bindingPath := TILEMAPS_DIR + TMName + "/Binding.gd"
	var tileSetPath := TILEMAPS_DIR + TMName + "/TileSet.tres"
	var success := SCRIPTS_GEN.generate_binding_script(LibK.TS.get_autotile_ids(tileSet),
		bindingPath, tileSetPath, logFunc)
	if(not success):
		logFunc.call_func(["Failed to generate binding script for: ", TMName, "path: ", tileSetPath], false)
		return false
	
	# Update offset based on tile size
	tileSet = _update_tile_texture_offset(tileSet, logFunc)
	
	var result := ResourceSaver.save(tileSetDir, tileSet)
	if(result != OK):
		logFunc.call_func(["Failed to save TileSet: ", tileSetDir], false)
		return false
	logFunc.call_func(["[b]Finished updating TileSet: [/b]", TMName, "\n"], false)
	return true

# For tiles bigger than one cell offset texture accordingly
static func _update_tile_texture_offset(tileSet:TileSet, logFunc:FuncRef) -> TileSet:
	logFunc.call_func(["\t[b]< updating tile offset[/b]"], false)
	for tileID in tileSet.get_tiles_ids():
		var tileSize:Vector2 = tileSet.autotile_get_size(tileID)
		var tileMode:int = tileSet.tile_get_tile_mode(tileID)
		if tileMode == TileSet.SINGLE_TILE:
			continue
		
		if tileSize[0] > DATA.TILEMAPS.BASE_SCALE or tileSize[1] > DATA.TILEMAPS.BASE_SCALE:
			var offsetSizeX:int = DATA.TILEMAPS.BASE_SCALE - int(tileSize[0])
			var offsetSizeY:int = DATA.TILEMAPS.BASE_SCALE - int(tileSize[1])
			tileSet.tile_set_texture_offset(tileID,Vector2(offsetSizeX, offsetSizeY))
			logFunc.call_func(["\tUpdated tile offset: ", tileSet.tile_get_name(tileID)], false)
	logFunc.call_func(["\t[b]> updating tile offset[/b]"], false)
	
	return tileSet

static func _update_TileMaps(logFunc:FuncRef) -> void:
	var TMData:Dictionary = TILESET_GEN.get_TMdata(TILEMAPS_DIR, logFunc)
	for TMName in TMData:
		var tileSetDir = TILEMAPS_DIR + TMName + "/TileSet.tres"
		var tileSet:TileSet = load(tileSetDir)
		if(not _update_TileMap(TMName, tileSet, logFunc)):
			logFunc.call_func(["Failed to update TileMap: ", TMName], true)

static func _update_TileMap(TMName:String, tileSet:TileSet, logFunc:FuncRef) -> bool:
	var tileMapPath = TILEMAPS_DIR + TMName + "/" + TMName + ".tscn"
	if not LibK.Files.file_exist(tileMapPath):
		var result := _create_new_TileMap(tileMapPath, TMName, tileSet)
		if(result != OK):
			logFunc.call_func(["Failed to create new TileMap", TMName], true)
			return false
	
	logFunc.call_func(["[b]Updating TileMap: [/b]", TMName], false)
	var tileMapScene = load(tileMapPath)
	var tileMap = tileMapScene.instance()
	
	# Update TileMap settings (settings below will be updated)
	tileMap.cell_size = TILE_SIZE
	
	# Pack and save TileMap
	var scene = PackedScene.new()
	scene.pack(tileMap)
	var result := ResourceSaver.save(tileMapPath,scene)
	if(result != OK):
		logFunc.call_func(["Failed to save TileSet: ", tileMapPath], false)
		return false
	logFunc.call_func(["[b]finished updating TileMap: [/b]", TMName, "\n"], false)
	return true

static func _create_new_TileMap(tmPath:String, tmName:String, tileSet:TileSet) -> int:
	var tileMap := TileMap.new()
	tileMap.tile_set = tileSet
	tileMap.set_name(tmName)
	var scene := PackedScene.new()
	scene.pack(tileMap)
	return ResourceSaver.save(tmPath,scene)
