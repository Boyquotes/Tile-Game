### ----------------------------------------------------
### Desc
### ----------------------------------------------------

extends Script
class_name MapSave

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const SQLite := preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
const SAVE_FOLDER_PATH:String = "res://Resources/SavetableData/SavedMaps/"

enum TS_KEYS {tileID,tileName} # List of all table keys (first is primary key)

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

static func _get_new_MapSave_template(savePath:String, TileMaps:Array):
	var DB := SQLite.new()
	DB.path = savePath
	DB.verbosity_level = 0
	
	DB.open_db()
	for tileMap in TileMaps:
		var TSName:String = tileMap.get_name()
		var tileSet:TileSet = tileMap.tile_set
		
		var tileIDs:Array = tileSet.get_tiles_ids()
		var tileNames:Array = LibK.TS.get_tile_names(tileSet)
		
		# Get table content
		var tableData := Dictionary()
		for key in TS_KEYS: tableData[key] = null
		
		for index in range(tileNames.size()):
			tableData[TS_KEYS.keys()[TS_KEYS.tileName]] = tileIDs[index]
			tableData[TS_KEYS.keys()[TS_KEYS.tileID]] = tileNames[index]
		
		DB.create_table(TSName, tableData)
	
	DB.close_db()


static func create_new_MapSave(saveName:String, TileMaps:Array) -> bool:
	var savePath := SAVE_FOLDER_PATH + saveName + ".db"
	
	if OS.move_to_trash(ProjectSettings.globalize_path(savePath)) != OK:
		Logger.logErr(["Unable to delete save file: ", savePath], get_stack())
		return false
		
	if LibK.Files.create_empty_file(savePath) != OK:
		Logger.logErr(["Unable to create empty save file: ", savePath], get_stack())
		return false
	
	
	
	return true
