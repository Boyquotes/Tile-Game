
### ----------------------------------------------------
# Manages sql save
### ----------------------------------------------------

extends "res://Global/Classes/Custom/Save/SQLSaveBase.gd"
class_name SQLSave

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# List of loaded chunks from sql to cache variables
var SQLLoadedChunks := Array() # [ChunkPos, ChunkPos ...]

# Holds TileSet data (not meant to be editet directly!)
# {MAPDATA_KEYS.TSData: { TSName:{PackedPos:TileData} } }
var MapData := Dictionary() 

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
	
	# Initialize TS_CONTROL
	var tempArr = str2var(sql_load_compressed(TABLE_NAMES.keys()[TABLE_NAMES.METADATA_TABLE], "TS_CONTROL"))
	if(not tempArr is Dictionary):
		Logger.logErr(["Failed do access TS_CONTROL from SQL save, str2var is not Dictionary: ", SAVE_PATH], get_stack())
		return false
	
	TS_CONTROL = tempArr

	# Initialize MapData
	for key in MAPDATA_KEYS:
		MapData[key] = {}

	return true
	
# If save already exists, create a new one and put old one in trash
func create_new_save(TileMaps:Array) -> bool:
	if(LibK.Files.file_exist(SAVE_PATH)):
		if(OS.move_to_trash(ProjectSettings.globalize_path(SAVE_PATH)) != OK):
			Logger.logErr(["Unable to delete save file: ", SAVE_PATH], get_stack())
			return false
	
	var result := LibK.Files.create_empty_file(SAVE_PATH)
	if(result != OK):
		Logger.logErr(["Unable to create empty save file: ", SAVE_PATH, ", err: ", result], get_stack())
		return false

	var isOK := true
	for TID in TABLE_NAMES.values():
		var tableName:String = TABLE_NAMES.keys()[TID]
		isOK = isOK and add_table(tableName, TABLE_CONTENT)
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
	
	if not MapData[MAPDATA_KEYS.TSData].has(TSName): MapData[MAPDATA_KEYS.TSData][TSName] = {}

	MapData[MAPDATA_KEYS.TSData][TSName][str(posV3)] = str(tileData)
	return true

# Returns tile on a given position, returns a new empty tiledata on fail
func get_tile_on(TSName:String, posV3:Vector3) -> TileData:
	if not TS_CONTROL.has(TSName):
		Logger.logErr(["TSName doesnt exist in available TileSets: " + TSName], get_stack())
		return TileData.new()
	
	if not MapData[MAPDATA_KEYS.TSData].has(TSName):
		Logger.logErr(["TSName doesnt exist in TSData: " + TSName], get_stack())
		return TileData.new()
	
	if not MapData[MAPDATA_KEYS.TSData][TSName].has(str(posV3)):
		return TileData.new()
	
	var tileData := TileData.new()
	return tileData.from_str(MapData[MAPDATA_KEYS.TSData][TSName][str(posV3)])

# Removes TileData on a given position
func remove_tile_on(TSName:String, posV3:Vector3) -> bool:
	if not TS_CONTROL.has(TSName):
		Logger.logErr(["TSName doesnt exist in available TileSets: " + TSName], get_stack())
		return false
	
	if not MapData[MAPDATA_KEYS.TSData].has(TSName):
		Logger.logErr(["TSName doesnt exist in TSData: " + TSName], get_stack())
		return false
	
	MapData[MAPDATA_KEYS.TSData][TSName].erase(str(posV3))
	return true

### ----------------------------------------------------
# Data from sql management
### ----------------------------------------------------


# Load data from SQLChunk to MapData
func _load_SQLChunk(SQLChunkPos:Vector3) -> void:
	var converted = str2var(sql_load_compressed(TABLE_NAMES.keys()[TABLE_NAMES.MAPDATA_TABLE], SQLChunkPos))
	if(not converted is Dictionary):
		if(converted == ""): SQLLoadedChunks.append(SQLChunkPos)
		Logger.logErr(["Converted loaded sql chunk is not a Dictionary! Pos: ", SQLChunkPos], get_stack())
		return
	
	for key in MAPDATA_KEYS:
		if(not converted.has(key)):
			Logger.logErr(["Converted loaded sql chunk is missing MAPDATA_KEYS key! Pos: ", SQLChunkPos, ", key: ", key], get_stack())
			continue
		MapData[key].merge(converted[key])
	SQLLoadedChunks.append(SQLChunkPos)

# Load data from MapData to SQLChunk
func _unload_SQLChunk(SQLChunkPos:Vector3) -> void:
	var PosToUnload = LibK.Vectors.vec3_get_pos_in_chunk(SQLChunkPos, MAPDATA_CHUNK_SIZE)
	var DictToSave = {}
	for key in MAPDATA_KEYS:
		DictToSave[key] = {}
		for posV3 in PosToUnload:
			if(not DictToSave[key].has(posV3)): continue
			DictToSave[key][posV3] = MapData[key][posV3]
			MapData[key].erase(posV3)
	
	sql_save_compressed(var2str(DictToSave), TABLE_NAMES.keys()[TABLE_NAMES.MAPDATA_TABLE], SQLChunkPos)
	SQLLoadedChunks.erase(SQLChunkPos)

# Loads requested data from sql database
# If data is being read from tiles close this should not cause much of performance drag
func _update_SQLLoadedChunks(posV3:Vector3) -> void:
	var SQLChunkPos := LibK.Vectors.scale_down_vec3(posV3, MAPDATA_CHUNK_SIZE)
	if(SQLLoadedChunks.has(SQLChunkPos)): return # Chunk already loaded from sql
	
	_load_SQLChunk(SQLChunkPos)
	# Unload old chunks that are not in range (iterate backwards)
	for i in range(SQLLoadedChunks.size() - 1, -1, -1):
		if(SQLLoadedChunks[i].distance_to(SQLChunkPos)>MAPDATA_UNLOAD_DS):
			_unload_SQLChunk(SQLLoadedChunks[i])

	






