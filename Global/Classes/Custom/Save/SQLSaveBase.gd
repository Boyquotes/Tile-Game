### ----------------------------------------------------
# Handles communication with SQLite directly
### ----------------------------------------------------

extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const SQLite := preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
const SQLCOMPRESSION = 2  # Compression mode, https://docs.godotengine.org/en/stable/classes/class_file.html#enum-file-compressionmode

var SQL_DB_GLOBAL:SQLite  # SQLite object assigned to SaveManager
var SAVE_PATH:String      # Database path
var beVerbose:bool        # For debug purposes

const SQL_DB_CHUNK_SIZE = 64

# Names of all tables that need to be created
enum TABLE_NAMES {METADATA_TABLE, TSDATA_TABLE}
const TABLES_DATA = {
    # Stores general data that doesnt need to be compressed
    TABLE_NAMES.METADATA_TABLE: {
        "DataName":{"primary_key":true,"data_type":"text", "not_null": true},
        "Data":{"data_type":"text", "not_null": true},
    },
    # Stores compressed chunk data
    TABLE_NAMES.TSDATA_TABLE: { 
        "ChunkPos":{"primary_key":true, "data_type":"text", "not_null": true},
        "CompressedData":{"data_type":"text", "not_null": true},
        "DecompressedSize":{"data_type":"int", "not_null": true},
    },
}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


# Class requires instancing for convinience and performance
func _init(savePath:String, verbose = false) -> void:
    beVerbose = verbose
    SAVE_PATH = savePath
    SQL_DB_GLOBAL = SQLite.new()
    SQL_DB_GLOBAL.path = SAVE_PATH
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
    
    SQL_DB_GLOBAL.open_db()
    isOK = SQL_DB_GLOBAL.insert_row(TABLE_NAMES.keys()[TABLE_NAMES.METADATA_TABLE],
            {"DataName":"TS_CONTROL", "Data":var2str(TSControlTemp).replace(" ", "")}) and isOK
    SQL_DB_GLOBAL.close_db()

    if(not isOK): Logger.logErr(["Failed to fill TSControl table"], get_stack())
    return isOK

# Compresses and saves data regarding a chunk
# Designed to compress big data chunks
func save_chunk_sql(chunkPos:Vector3, Str:String) -> void:
    var B64Str := Marshalls.utf8_to_base64(Str)
    var B64C := Marshalls.raw_to_base64(Marshalls.base64_to_raw(B64Str).compress(SQLCOMPRESSION))
    var values:String = "'" + str(chunkPos) + "','" + B64C + "','" + str(Str.length()) + "'"

    do_query("REPLACE INTO TSDATA_TABLE (ChunkPos,CompressedData,DecompressedSize) VALUES("+values+");")
    if(beVerbose): Logger.logMS(["Saved chunk to SQLite: ", chunkPos])

# Loads chunk from save, returns empty string if position not saved
func load_chunk_sql(chunkPos:Vector3) -> String:
    if (not row_exists("TSDATA_TABLE", "ChunkPos", str(chunkPos))): return ""
    var queryResult := get_query_result("SELECT CompressedData,DecompressedSize FROM TSDATA_TABLE WHERE ChunkPos='" + str(chunkPos) + "';")
    
    var B64C:String = queryResult[0]["CompressedData"]
    var DCSize:int = queryResult[0]["DecompressedSize"]
    var B64DC := Marshalls.raw_to_base64(Marshalls.base64_to_raw(B64C).decompress(DCSize,SQLCOMPRESSION))
    if(beVerbose): Logger.logMS(["Loaded chunk from SQLite: ", chunkPos])
    return Marshalls.base64_to_utf8(B64DC)

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
