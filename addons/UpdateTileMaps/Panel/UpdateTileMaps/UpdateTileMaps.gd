### ----------------------------------------------------
### Script automatically updates all TileMaps
### Requires predefined directory structure in order to work:
### TILEMAPS_DIR/TileMapName/TypeOfTile/SetName/[BG.png and Outline.png]
### ----------------------------------------------------

tool
extends "res://addons/UpdateTileMaps/Panel/UpdateTileMaps/TileSetData.gd"

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func start_script() -> void:
	update_TileSets()
	update_TileMaps()
	$ScriptsGenerator.generate_TILES_script(get_TileSets(), TILES_SCRIPT_DIR)

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
		emit_signal("logMessage", [LibK.Saving.saveResource(tileSetDir, TileSet.new())], false)
	
	var tileSet:TileSet = load(tileSetDir)
	emit_signal("logMessage", ["[b]Updating TileSet: [/b]", TMName], false)
	
	# Update tiles of material types (autotile and single tile excluding universal)
	tileSet = add_tile_types(tileSet,TMData[TMName],BITMASK_FLAGS)
	
	# Add autotile bounding script
	$ScriptsGenerator.generate_binding_script(LibK.TS.get_autotile_ids(tileSet),
	TILEMAPS_DIR + TMName + "/Binding.gd", TILEMAPS_DIR + TMName + "/TileSet.tres")
	
	# Update offset based on tile size
	tileSet = _update_tile_texture_offset(tileSet)
	
	emit_signal("logMessage", ["\t",LibK.Saving.saveResource(tileSetDir, tileSet)], false)
	emit_signal("logMessage", ["[b]Finished updating TileSet: [/b]", TMName, "\n"], false)


# For tiles bigger than one cell offset texture accordingly
func _update_tile_texture_offset(tileSet:TileSet) -> TileSet:
	emit_signal("logMessage", ["\t[b]< updating tile offset[/b]"], false)
	for tileID in tileSet.get_tiles_ids():
		var tileSize:Vector2 = tileSet.autotile_get_size(tileID)
		var tileMode:int = tileSet.tile_get_tile_mode(tileID)
		if tileMode == TileSet.SINGLE_TILE:
			continue
		
		if tileSize[0] > DATA.TILEMAPS.BASE_SCALE or tileSize[1] > DATA.TILEMAPS.BASE_SCALE:
			var offsetSizeX:int = DATA.TILEMAPS.BASE_SCALE - int(tileSize[0])
			var offsetSizeY:int = DATA.TILEMAPS.BASE_SCALE - int(tileSize[1])
			tileSet.tile_set_texture_offset(tileID,Vector2(offsetSizeX, offsetSizeY))
			emit_signal("logMessage", ["\tUpdated tile offset: ", tileSet.tile_get_name(tileID)], false)
	emit_signal("logMessage", ["\t[b]> updating tile offset[/b]"], false)
	
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
	
	emit_signal("logMessage", ["[b]Updating TileMap: [/b]", TMName], false)
	var tileMapScene = load(tileMapPath)
	var tileMap = tileMapScene.instance()
	
	# Update TileMap settings (settings below will be updated)
	tileMap.cell_size = TILE_SIZE
	
	# Pack and save TileMap
	var scene = PackedScene.new()
	scene.pack(tileMap)
	
	emit_signal("logMessage", ["\t",LibK.Saving.saveResource(tileMapPath,scene)], false)
	emit_signal("logMessage", ["[b]finished updating TileMap: [/b]", TMName, "\n"], false)


func _create_new_TileMap(tmPath:String, tmName:String, tileSet:TileSet) -> void:
	var tileMap = TileMap.new()
	tileMap.tile_set = tileSet
	tileMap.set_name(tmName)
	
	var scene = PackedScene.new()
	scene.pack(tileMap)
	emit_signal("logMessage", [LibK.Saving.saveResource(tmPath,scene)], false)
### ----------------------------------------------------
