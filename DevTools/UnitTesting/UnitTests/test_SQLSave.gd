### ----------------------------------------------------
### Desc
### ----------------------------------------------------
extends GutTestLOG

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const _MMS = preload("res://Scenes/SimulationManager/MapManager/MapManager.tscn")
var MapManager:Node = null

const SAV_FOLDER := "res://Temp"
const SAV_NAME := "UnitTest"


### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func before_each():
	MapManager = autoqfree(_MMS.instance())
	add_child(MapManager)

### ----------------------------------------------------
# UnitTests
### ----------------------------------------------------

func get_regular(sqlsave:SQLSave, TestPosV3:Array, SavedData:Dictionary, RTileMapName:String) -> void:
	var GetTimer = STimer.new(Time.get_ticks_msec())
	for posV3 in TestPosV3:
		var GetTD := sqlsave.get_tile_on(RTileMapName, posV3)
		assert_true(str(SavedData[posV3]) == str(GetTD), "Get TileData (create) content does not match: "+str(SavedData[posV3])+"=!"+str(GetTD)+", Pos:"+str(posV3))
	LOG_GUT(["Get time (msec) (regular): ", GetTimer.get_result()])

func get_bulk(sqlsave:SQLSave, TestChunks:Array, SavedData:Dictionary, RTileMapName:String) -> void:
	var GetTimer = STimer.new(Time.get_ticks_msec())
	for chunkPosV3 in TestChunks:
		var ChunkData := sqlsave.get_tiles_on_chunk(RTileMapName, chunkPosV3, SQLSave.MAPDATA_CHUNK_SIZE)
		for posV3 in ChunkData:
			assert_true(str(SavedData[posV3]) == str(ChunkData[posV3]), "Get TileData (create) content does not match: "+str(SavedData[posV3])+"=!"+str(ChunkData[posV3])+", Pos:"+str(posV3))
	LOG_GUT(["Get time (msec) (bulk): ", GetTimer.get_result()])

func test_SQLSave():
	var sqlsave := SQLSave.new(SAV_NAME, SAV_FOLDER)
	assert_true(sqlsave.create_new_save(MapManager.TileMaps), "Failed to create new save")
	assert_true(sqlsave.initialize(), "Failed to initialize SQLSave")
	assert_true(sqlsave.check_compatible(MapManager.TileMaps), "Tilemaps are not compatible")

	var RTileMap:TileMap = MapManager.TileMaps[randi()%MapManager.TileMaps.size()]
	var RTileMapName:String = RTileMap.get_name()
	var TileIds:Array = RTileMap.tile_set.get_tiles_ids()
	
	# Create a block of tiles to save
	var TestPosV3 := []
	var TestChunks := []
	
	for z in range(3):
		for x in range(1):
			for y in range(1):
				TestChunks.append(Vector3(x,y,z))
				TestPosV3.append_array(LibK.Vectors.vec3_get_pos_in_chunk(Vector3(x,y,z), SQLSave.MAPDATA_CHUNK_SIZE))
	
	# Set tiles in save and create a dict copy to compare to later
	var SavedData := {}
	var SetTimer = STimer.new(Time.get_ticks_msec())
	for posV3 in TestPosV3:
		var rID:int = TileIds[randi()%TileIds.size()]
		var RTD := TileData.new(rID)
		assert_true(sqlsave.set_tile_on(RTileMapName, posV3, RTD), "Failed to set tile on position: "+str(posV3))
		SavedData[posV3] = TileData.new(rID)
	LOG_GUT(["Set time (msec): ", SetTimer.get_result()])
	
	# Get tiles from save
	get_regular(sqlsave, TestPosV3, SavedData, RTileMapName)
	get_bulk(sqlsave, TestChunks, SavedData, RTileMapName)

	assert_true(sqlsave.save_to_sqlDB(), "Failed to save")
	assert_true(sqlsave.MapData[SQLSave.MAPDATA_KEYS.TSData].size() == 0, 
		"MapData should be empty! Size: " + str(sqlsave.MapData[SQLSave.MAPDATA_KEYS.TSData].size()) +", content: "+ str(sqlsave.MapData[SQLSave.MAPDATA_KEYS.TSData]))
	sqlsave = null

	# Simulate trying to access data after save
	var sqlload := SQLSave.new(SAV_NAME, SAV_FOLDER)
	assert_true(sqlload.initialize(), "Failed to initialize SQLSave")
	assert_true(sqlload.check_compatible(MapManager.TileMaps), "Tilemaps are not compatible")
	
	# Get tiles from save
	var LGetTimer = STimer.new(Time.get_ticks_msec())
	for posV3 in TestPosV3:
		var GetTD := sqlload.get_tile_on(RTileMapName, posV3)
		assert_true(str(SavedData[posV3]) == str(GetTD), "Get TileData (load) content does not match: "+str(SavedData[posV3])+"=!"+str(GetTD)+", Pos:"+str(posV3))
	LOG_GUT(["Get load time (msec): ", LGetTimer.get_result()])

	assert_true(sqlload.save_to_sqlDB(), "Failed to save loaded")
	assert_true(LibK.Files.delete_file(sqlload.SQL_DB_GLOBAL.path) == OK, "Failed to delete save")
