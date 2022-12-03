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
	Logger.logMS(["----------------------------------------------------"])
	Logger.logMS(["Starting UpdateTileMaps script.\n"])
	update_TileMaps()
	Logger.logMS(["Finished UpdateTileMaps script."])
	Logger.logMS(["----------------------------------------------------\n"])


# Main function executing all updates
func update_TileMaps() -> void:
	Logger.logMS(["Updating TileMaps..."])
	var TMData:Dictionary = get_TMdata()
	for TMName in TMData: _update_TileMap(TMName, _get_TileSet(TMName,TMData))
	Logger.logMS(["Finished updating TileMaps.\n"])


# Creates a tileset, fills it with generated tiles
func _get_TileSet(TMName:String,TMData:Dictionary) -> TileSet:
	var tileSetDir = TILEMAPS_DIR+TMName+"/TileSet.tres"
	if not LibK.Files.file_exist(tileSetDir):
		var TS:TileSet = TileSet.new()
		var _result:int = ResourceSaver.save(tileSetDir,TS)
		Logger.logMS(["Created new TileSet for ",TMName])
	
	var tileSet:TileSet = load(tileSetDir)
	
	# Update tiles of material types (autotile and single tile excluding universal)
	Logger.logMS(["Updating tile types for ",TMName])
	tileSet = TSCreator.add_tile_types(tileSet,TMData[TMName],BITMASK_FLAGS)
	Logger.logMS(["Finished updating tile types for ",TMName])
	
	# Update offset based on tile size
	tileSet = _update_tile_texture_offset(tileSet)
	
	# Save TileSet
	var result:int = ResourceSaver.save(tileSetDir,tileSet)
	Logger.logMS(["Updated TileSet for ", TMName, " ", result,"\n"])
	
	return tileSet


# Updates TileMap
func _update_TileMap(TMName:String, tileSet:TileSet) -> void:
	# Check if TileMap exists
	var tileMapPath = TILEMAPS_DIR+TMName+"/"+TMName+".tscn"
	if not LibK.Files.file_exist(tileMapPath):
		_create_new_TileMap(tileMapPath, TMName, tileSet)
	
	# Load TileMap 
	var tileMapScene = load(tileMapPath)
	var tileMap = tileMapScene.instance()
	
	# Update TileMap settings (settings below will be updated)
	tileMap.cell_size = TILE_SIZE
	
	# Add autotile bounding script
	TSMerge.generate_merge_script(LibK.TS.get_autotile_ids(tileSet),
	TILEMAPS_DIR + TMName + "/Binding.gd", TILEMAPS_DIR+TMName+"/TileSet.tres")
	
	# Pack and save TileMap
	var scene = PackedScene.new()
	scene.pack(tileMap)
	var result = ResourceSaver.save(tileMapPath,scene)
	Logger.logMS(["Updated TileMap: ", TMName, " ", result])


# Creates new TileMap with given TileSet and name
func _create_new_TileMap(tmPath:String, tmName:String, tileSet:TileSet) -> void:
	var tileMap = TileMap.new()
	tileMap.tile_set = tileSet
	tileMap.set_name(tmName)
	
	# Create new Scene (TileMap node)
	var scene = PackedScene.new()
	scene.pack(tileMap)
	
	# Save
	var result:int = ResourceSaver.save(tmPath,scene)
	Logger.logMS(["TileMap created: " + tmName, " ", result])


# For tiles bigger than one cell offset texture accordingly
func _update_tile_texture_offset(tileSet:TileSet) -> TileSet:
	for tileID in tileSet.get_tiles_ids():
		var tileSize:Vector2 = tileSet.autotile_get_size(tileID)
		var tileMode:int = tileSet.tile_get_tile_mode(tileID)
		if tileMode == TileSet.SINGLE_TILE:
			continue
		
		if tileSize[0] > DATA.Map.BASE_SCALE or tileSize[1] > DATA.Map.BASE_SCALE:
			var offsetSizeX:int = DATA.Map.BASE_SCALE - int(tileSize[0])
			var offsetSizeY:int = DATA.Map.BASE_SCALE - int(tileSize[1])
			tileSet.tile_set_texture_offset(tileID,Vector2(offsetSizeX, offsetSizeY))
			Logger.logMS(["Updated tile offset: ", tileSet.tile_get_name(tileID)])
	
	return tileSet


