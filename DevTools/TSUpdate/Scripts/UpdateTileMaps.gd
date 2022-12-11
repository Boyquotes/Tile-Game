### ----------------------------------------------------
### Script automatically updates all TileMaps
### Requires predefined directory structure in order to work:
### > DATA.TILEMAPS_DIR
### 	> TileMapName
### 		> TypeOfTile (Autotile or Single)
### 			> SetName
### 				> BG.png and Outline.png
### ----------------------------------------------------
tool
extends "res://DevTools/TSUpdate/Scripts/Dependencies/TSData.gd"

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const TSMerge:Script = preload("res://DevTools/TSUpdate/Scripts/Dependencies/BindingGenerator.gd")
const TSCreator:Script = preload("res://DevTools/TSUpdate/Scripts/Dependencies/TileSetCreator.gd")

var TILE_SIZE:Vector2 = Vector2(DATA.Map.BASE_SCALE, DATA.Map.BASE_SCALE)

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _run() -> void:
	Logger.logMS(["--------------","[B]Starting script","--------------"])
	update_TileSets()
	update_TileMaps()
	Logger.logMS(["--------------","[B]Finished script","--------------"])


### ----------------------------------------------------
# TileSet Update
### ----------------------------------------------------
func update_TileSets() -> void:
	var TMData:Dictionary = get_TMdata()
	for TMName in TMData: _update_TileSet(TMName,TMData)


# Creates a tileset, fills it with generated tiles
func _update_TileSet(TMName:String,TMData:Dictionary) -> void:
	var tileSetDir = TILEMAPS_DIR + TMName + "/TileSet.tres"
	
	if not LibK.Files.file_exist(tileSetDir):
		Logger.logMS([LibK.Saving.saveResource(tileSetDir, TileSet.new())])
	
	var tileSet:TileSet = load(tileSetDir)
	Logger.logMS(["[B]Updating TileSet: ", TMName])
	
	# Update tiles of material types (autotile and single tile excluding universal)
	Logger.logMS(["[TAB][B]< Adding tile types"])
	tileSet = TSCreator.add_tile_types(tileSet,TMData[TMName],BITMASK_FLAGS)
	Logger.logMS(["[TAB][B]> Adding tile types"])
	
	# Add autotile bounding script
	TSMerge.generate_merge_script(LibK.TS.get_autotile_ids(tileSet),
	TILEMAPS_DIR + TMName + "/Binding.gd", TILEMAPS_DIR+TMName+"/TileSet.tres")
	
	# Update offset based on tile size
	tileSet = _update_tile_texture_offset(tileSet)
	
	Logger.logMS(["[TAB]",LibK.Saving.saveResource(tileSetDir, tileSet)])
	Logger.logMS(["[B]Finished updating TileSet: ", TMName])


# For tiles bigger than one cell offset texture accordingly
func _update_tile_texture_offset(tileSet:TileSet) -> TileSet:
	Logger.logMS(["[TAB][B]< updating tile offset"])
	for tileID in tileSet.get_tiles_ids():
		var tileSize:Vector2 = tileSet.autotile_get_size(tileID)
		var tileMode:int = tileSet.tile_get_tile_mode(tileID)
		if tileMode == TileSet.SINGLE_TILE:
			continue
		
		if tileSize[0] > DATA.Map.BASE_SCALE or tileSize[1] > DATA.Map.BASE_SCALE:
			var offsetSizeX:int = DATA.Map.BASE_SCALE - int(tileSize[0])
			var offsetSizeY:int = DATA.Map.BASE_SCALE - int(tileSize[1])
			tileSet.tile_set_texture_offset(tileID,Vector2(offsetSizeX, offsetSizeY))
			Logger.logMS(["[TAB]Updated tile offset: ", tileSet.tile_get_name(tileID)])
	Logger.logMS(["[TAB][B]> updating tile offset"])
	
	return tileSet
### ----------------------------------------------------

### ----------------------------------------------------
# TileMap Update
### ----------------------------------------------------
func update_TileMaps() -> void:
	var TMData:Dictionary = get_TMdata()
	for TMName in TMData:
		var tileSetDir = TILEMAPS_DIR + TMName + "/TileSet.tres"
		var tileSet:TileSet = load(tileSetDir)
		_update_TileMap(TMName, tileSet)


func _update_TileMap(TMName:String, tileSet:TileSet) -> void:
	var tileMapPath = TILEMAPS_DIR + TMName + "/" + TMName + ".tscn"
	if not LibK.Files.file_exist(tileMapPath):
		_create_new_TileMap(tileMapPath, TMName, tileSet)
	
	Logger.logMS(["[B]Updating TileMap: ", TMName])
	var tileMapScene = load(tileMapPath)
	var tileMap = tileMapScene.instance()
	
	# Update TileMap settings (settings below will be updated)
	tileMap.cell_size = TILE_SIZE
	
	# Pack and save TileMap
	var scene = PackedScene.new()
	scene.pack(tileMap)
	
	Logger.logMS(["[TAB]",LibK.Saving.saveResource(tileMapPath,scene)])
	Logger.logMS(["[B]finished updating TileMap: ", TMName])


func _create_new_TileMap(tmPath:String, tmName:String, tileSet:TileSet) -> void:
	var tileMap = TileMap.new()
	tileMap.tile_set = tileSet
	tileMap.set_name(tmName)
	
	var scene = PackedScene.new()
	scene.pack(tileMap)
	Logger.logMS([LibK.Saving.saveResource(tmPath,scene)])
### ----------------------------------------------------
