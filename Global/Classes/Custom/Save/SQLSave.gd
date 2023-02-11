
### ----------------------------------------------------
# Manages sql save
### ----------------------------------------------------

extends "res://Global/Classes/Custom/Save/SQLSaveBase.gd"
class_name SQLSave

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# List of loaded chunks from sql to cache variables
var SQLLoadedChunks:Array # [ChunkPos, ChunkPos ...]

# Holds TileSet data (not meant to be editet directly!)
export var TSData := Dictionary() # { TSName:{PackedPos:TileData} }

# Holds TileSet data
var TS_CONTROL := Dictionary() # { TSName:{tileID:tileName} }

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _init(savePath:String, verbose:bool = false).(savePath, verbose) -> void:
	pass

# Should be called after init before trying to acess data from save
# Loads all metadata to cache variables
func initialize() -> bool:
	if(not LibK.Files.file_exist(SAVE_PATH)):
		Logger.logErr(["Unable to initialize save, file doesnt exist: ", SAVE_PATH], get_stack())
		return false

	var temp := get_query_result("SELECT Data FROM METADATA_TABLE WHERE DataName='TS_CONTROL';")
	if(temp.empty()):
		Logger.logErr(["Failed do access TS_CONTROL from SQL save: ", SAVE_PATH], get_stack())
		return false
	
	TS_CONTROL = str2var(temp[0]["Data"])

	return true
	
# If save already exists, create a new one and put old one in trash
func create_new_save(TileMaps:Array) -> bool:
	if(LibK.Files.file_exist(SAVE_PATH)):
		if OS.move_to_trash(ProjectSettings.globalize_path(SAVE_PATH)) != OK:
			Logger.logErr(["Unable to delete save file: ", SAVE_PATH], get_stack())
			return false
	
	var result := LibK.Files.create_empty_file(SAVE_PATH)
	if(result != OK):
		Logger.logErr(["Unable to create empty save file: ", SAVE_PATH, ", err: ", result], get_stack())
		return false

	var isOK := true
	for TID in TABLE_NAMES.values():
		var tableName:String = TABLE_NAMES.keys()[TID]
		isOK = isOK and add_table(tableName, TABLES_DATA[TID])
	isOK = isOK and fill_METADATA_TABLE(TileMaps)
	
	if(not isOK):
		Logger.logErr(["Failed to create tables: ", SAVE_PATH], get_stack())
		return isOK
	Logger.logMS(["Created DataBase at: ", SAVE_PATH])
	return isOK

# Check if the current tilemaps are compatible with TS_CONTROL tilemaps
func check_compatible(TileMaps:Array) -> bool:
	var isOK := true
	for tileMap in TileMaps:
		var TSName:String = tileMap.get_name()
		var tileSet:TileSet = tileMap.tile_set
		
		if not TS_CONTROL.has(TSName):
			Logger.logErr(["TS_CONTROL is missing TSName: " + TSName], get_stack())
			isOK = false
			continue
		
		var tileNamesIDs = LibK.TS.get_tile_names_and_IDs(tileSet)
		for index in range(tileNamesIDs.size()):
			var tileName:String = tileNamesIDs[index][0]
			var tileID:int = tileNamesIDs[index][1]
			if not TS_CONTROL[TSName].has(tileID):
				Logger.logErr(["TS_CONTROL is missing tileID: ", tileID], get_stack())
				isOK = false
				continue
			
			if TS_CONTROL[TSName][tileID] != tileName:
				Logger.logErr(["TileName doesn't match for tileID: ", tileID, " | ", tileName, " != ", TS_CONTROL[TSName][tileID]],
					get_stack())
				isOK = false
				continue
	return isOK

### ----------------------------------------------------
# Map - Set / Get / Remove
### ----------------------------------------------------


# Sets TileData on a given position
func set_tile_on(TSName:String, posV3:Vector3, tileData:TileData) -> bool:
	if not TS_CONTROL.has(TSName):
		Logger.logErr(["TSName doesnt exist in available TileSets: " + TSName], get_stack())
		return false
	
	if not TS_CONTROL[TSName].has(tileData.tileID):
		Logger.logErr(["tileID doesnt exist in available TileSets: " + str(tileData.tileID)], get_stack())
		return false
	
	if not TSData.has(TSName): TSData[TSName] = {}

	TSData[TSName][str(posV3)] = str(tileData)
	return true

# Returns tile on a given position, returns a new empty tiledata on fail
func get_tile_on(TSName:String, posV3:Vector3) -> TileData:
	if not TS_CONTROL.has(TSName):
		Logger.logErr(["TSName doesnt exist in available TileSets: " + TSName], get_stack())
		return TileData.new()
	
	if not TSData.has(TSName):
		Logger.logErr(["TSName doesnt exist in TSData: " + TSName], get_stack())
		return TileData.new()
	
	if not TSData[TSName].has(str(posV3)):
		return TileData.new()
	
	var tileData := TileData.new()
	return tileData.from_str(TSData[TSName][str(posV3)])

# Removes TileData on a given position
func remove_tile_on(TSName:String, posV3:Vector3) -> bool:
	if not TS_CONTROL.has(TSName):
		Logger.logErr(["TSName doesnt exist in available TileSets: " + TSName], get_stack())
		return false
	
	if not TSData.has(TSName):
		Logger.logErr(["TSName doesnt exist in TSData: " + TSName], get_stack())
		return false
	
	TSData[TSName].erase(str(posV3))
	return true

### ----------------------------------------------------
# Data from sql management
### ----------------------------------------------------

# Loads requested data from sql database
func _update_SQLLoadedChunks(posV3:Vector3) -> void:
	var SQLChunkPos := LibK.Vectors.scale_down_vec3(posV3, SQL_DB_CHUNK_SIZE)
	if(SQLLoadedChunks.has(SQLChunkPos)): return
	
	var LoadedString = load_chunk_sql(SQLChunkPos)
	if(LoadedString != ""):
		var converted = str2var(LoadedString)
		if(not converted is Array):
			Logger.logErr(["Converted loaded sql chunk is not an Array! Pos: ", SQLChunkPos], get_stack())
			return




	SQLLoadedChunks.append(SQLChunkPos)






