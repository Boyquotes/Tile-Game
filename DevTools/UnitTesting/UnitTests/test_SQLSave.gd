### ----------------------------------------------------
### Desc
### ----------------------------------------------------
extends GutTestLOG

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const _MMS = preload("res://Scenes/SimulationManager/MapManager/MapManager.tscn")
var MapManager:Node = null

const SAVE_PATH := "res://Temp/Test"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func before_each():
	MapManager = autoqfree(_MMS.instance())
	add_child(MapManager)

### ----------------------------------------------------
# UnitTests
### ----------------------------------------------------

func test_SQLSave():
	var sqlsave := SQLSave.new(SAVE_PATH)
	assert_true(sqlsave.create_new_save(MapManager.TileMaps), "Failed to create new save")
	assert_true(sqlsave.initialize(), "Failed to initialize SQLSave")
	assert_true(sqlsave.check_compatible(MapManager.TileMaps), "Tilemaps are not compatible")

	var RTileMap:TileMap = MapManager.TileMaps[randi()%MapManager.TileMaps.size()]
	var RTileMapName:String = RTileMap.get_name()
	var TileIds:Array = RTileMap.tile_set.get_tiles_ids()
	
	# Create a block of tiles to save
	var TestPosV3 := []
	for x in range(32):
		for y in range(1):
			for z in range(1):
				TestPosV3.append(Vector3(x,y,z))
	
	# Set tiles in save and create a dict copy to compare to later
	var SavedData := {}
	var SetTimer = STimer.new(Time.get_ticks_msec())
	for posV3 in TestPosV3:
		var rID:int = TileIds[randi()%TileIds.size()]
		var RTD := TileData.new(rID)
		assert_true(sqlsave.set_tile_on(RTileMapName, posV3, RTD), "Failed to set tile on position: "+str(posV3))
		SavedData[posV3] = TileData.new(rID)
	LOG_GUT(["Set time (msec): ", SetTimer.get_result()])

	var GetTimer = STimer.new(Time.get_ticks_msec())
	for posV3 in TestPosV3:
		var GetTD := sqlsave.get_tile_on(RTileMapName, posV3)
		assert_true(str(SavedData[posV3]) == str(GetTD), "Set TileData content does not match: "+str(SavedData[posV3])+"=!"+str(GetTD))
	LOG_GUT(["Get time (msec): ", GetTimer.get_result()])

	sqlsave.save_to_sqlDB()
	sqlsave = null

	# Simulate trying to access data after save
	var sqlload := SQLSave.new(SAVE_PATH, true)
	assert_true(sqlload.initialize(), "Failed to initialize SQLSave")
	assert_true(sqlload.check_compatible(MapManager.TileMaps), "Tilemaps are not compatible")
	
	var LGetTimer = STimer.new(Time.get_ticks_msec())
	for posV3 in TestPosV3:
		var GetTD := sqlload.get_tile_on(RTileMapName, posV3)
		assert_true(str(SavedData[posV3]) == str(GetTD), "Set TileData content does not match: "+str(SavedData[posV3])+"=!"+str(GetTD))
	LOG_GUT(["Get load time (msec): ", LGetTimer.get_result()])

	assert_true(LibK.Files.delete_file(SAVE_PATH) == OK, "Failed to delete save")
