### ----------------------------------------------------
# Handles communication with SQLite directly
### ----------------------------------------------------

extends Reference

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const SQLite := preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
const SQLCOMPRESSION = 2  # Compression mode, https://docs.godotengine.org/en/stable/classes/class_file.html#enum-file-compressionmode

var SQL_DB_GLOBAL:SQLite  # SQLite object assigned to SaveManager
var DEST_PATH:String      # Source of save
var FILE_NAME:String	  # Database name
var FILE_DIR:String       # Database dir
var beVerbose:bool        # For debug purposes

const MAPDATA_CHUNK_SIZE = 64 # Size of SQLite data chunk
const MAPDATA_UNLOAD_DS = 3   # Decides when to unload chunk (distance from last request)

# Names of all tables that need to be created
enum TABLE_NAMES {METADATA_TABLE, MAPDATA_TABLE}
# Content of all tables
const TABLE_CONTENT = { 
	"Key":{"primary_key":true,"data_type":"text", "not_null": true},
	"CData":{"data_type":"text", "not_null": true},
	"DCSize":{"data_type":"int", "not_null": true},
}

# Names of keys stored in mapdata sql chunk
enum MAPDATA_KEYS {TSData}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


# Class requires instancing for convinience and performance
func _init(fileName:String, fileDir:String, verbose = false) -> void:
	beVerbose = verbose
	FILE_DIR = fileDir
	FILE_NAME = fileName
	DEST_PATH = FILE_DIR + FILE_NAME +".db"

	SQL_DB_GLOBAL = SQLite.new()
	SQL_DB_GLOBAL.path = FILE_DIR + FILE_NAME +"_TEMP.db"
	SQL_DB_GLOBAL.verbosity_level = 0

# Called when creating new save to have a template of tileset tiles
func fill_METADATA_TABLE(TileMaps:Array) -> bool:
	var isOK:bool = true
	var TSControlTemp := Dictionary()
	for tileMap in TileMaps:
		var TSName:String = tileMap.get_name()
		var tileSet:TileSet = tileMap.tile_set
		
		TSControlTemp[TSName] = {}
		var tileNamesIDs = LibK.TS.get_tile_names_and_IDs(tileSet)
		for index in range(tileNamesIDs.size()):
			TSControlTemp[TSName][tileNamesIDs[index][1]] = tileNamesIDs[index][0]
	
	sql_save_compressed(var2str(TSControlTemp).replace(" ", ""), 
		TABLE_NAMES.keys()[TABLE_NAMES.METADATA_TABLE], "TS_CONTROL")

	if(not isOK): Logger.logErr(["Failed to fill TSControl table"], get_stack())
	return isOK

# Compresses and saves data in sqlite db
# Designed to compress big data chunks
func sql_save_compressed(Str:String, tableName:String, KeyVar) -> void:
	var B64C := LibK.Compression.compress_str(Str, SQLCOMPRESSION)
	var values:String = "'" + str(KeyVar) + "','" + B64C + "','" + str(Str.length()) + "'"
	do_query("REPLACE INTO "+tableName+" (Key,CData,DCSize) VALUES("+values+");")

	if(beVerbose): Logger.logMS(["Saved CData to SQLite: ", tableName, " ", KeyVar])

# Loads chunk from save, returns empty string if position not saved
func sql_load_compressed(tableName:String, KeyVar) -> String:
	if (not row_exists(tableName, "Key", str(KeyVar))): return ""
	var queryResult := get_query_result("SELECT CData,DCSize FROM "+tableName+" WHERE Key='"+str(KeyVar)+"';")

	if(beVerbose): Logger.logMS(["Loaded CData from SQLite: ", tableName, " ", KeyVar])
	return LibK.Compression.decompress_str(queryResult[0]["CData"], SQLCOMPRESSION, queryResult[0]["DCSize"])

### ----------------------------------------------------
# Queries, these are not meant to be used where speed matters (open and close db in every function which is slow)
### ----------------------------------------------------


# tableDict format:
# { columnName:{"data_type":"text", "not_null": true}, ... }
func add_table(tableName:String, tableDict:Dictionary) -> bool:
	var isOK := true
	SQL_DB_GLOBAL.open_db()
	isOK = SQL_DB_GLOBAL.create_table(tableName, tableDict) and isOK
	SQL_DB_GLOBAL.close_db()

	if(not isOK):
		Logger.logErr(["Unable to create table: ", tableName], get_stack())
		return false

	if(beVerbose): Logger.logMS(["Created table: ", tableName])
	return isOK

func table_exists(tableName:String) -> bool:
	SQL_DB_GLOBAL.open_db()
	SQL_DB_GLOBAL.query("SELECT name FROM sqlite_master WHERE type='table' AND name='" + tableName + "';")
	SQL_DB_GLOBAL.close_db()
	return SQL_DB_GLOBAL.query_result.size()>0

func column_exists(tableName:String, columnName:String) -> bool:
	var exists := false
	if(not table_exists(tableName)):
		Logger.logErr(["Table doesnt exist: ", tableName], get_stack())
		return false 
	
	SQL_DB_GLOBAL.open_db()
	SQL_DB_GLOBAL.query("PRAGMA table_info('" + tableName + "');")
	for element in SQL_DB_GLOBAL.query_result:
		if element["name"] == columnName: 
			exists = true
			break
	
	SQL_DB_GLOBAL.close_db()
	return exists

func row_exists(tableName:String, columnName:String, value:String):
	if(not column_exists(tableName, columnName)):
		Logger.logErr(["Column doesnt exist in table: ", tableName, ", ", columnName], get_stack())
		return false
	
	SQL_DB_GLOBAL.open_db()
	SQL_DB_GLOBAL.query("SELECT EXISTS(SELECT 1 FROM " + tableName + " WHERE " + columnName + "='" + value + "') LIMIT 1;")
	SQL_DB_GLOBAL.close_db()
	return SQL_DB_GLOBAL.query_result[0].values().has(1)

func get_query_result(query:String) -> Array:
	SQL_DB_GLOBAL.open_db()
	SQL_DB_GLOBAL.query(query)
	SQL_DB_GLOBAL.close_db()
	return SQL_DB_GLOBAL.query_result

func do_query(query:String) -> void:
	SQL_DB_GLOBAL.open_db()
	SQL_DB_GLOBAL.query(query)
	SQL_DB_GLOBAL.close_db()
