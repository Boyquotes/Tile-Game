### ----------------------------------------------------
### Desc
### ----------------------------------------------------
extends GutTestLOG

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const _MMS = preload("res://Scenes/SimulationManager/MapManager/MapManager.tscn")
var MapManager:Node = null

const SAVE_NAME := "Test"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func before_each():
	MapManager = autoqfree(_MMS.instance())
	add_child(MapManager)

### ----------------------------------------------------
# UnitTests
### ----------------------------------------------------

func test_save_and_load():
	LOG_GUT("Iterate through every possible tile")
	var yCord:int = 0
	for tileMap in MapManager.TileMaps:
		var TMName:String = tileMap.get_name()
		for tileID in tileMap.tile_set.get_tiles_ids():
			var posV3 := Vector3(0, yCord, 0)
			var tileData := TileData.new(tileID)
			assert_true(SAVE.CurrentMap.set_tile_on(TMName, posV3, tileData),
				"Unable to set tile on: " + TMName + " " + str(posV3))
			assert_eq(str(tileData), str(SAVE.CurrentMap.get_tile_on(TMName, posV3)),
				"tileData should match")
			yCord += 1
	
	LOG_GUT("save and load test")
	assert_true(SAVE.CM_save_current(SAVE_NAME),
		"Saving failed.")
	var MAPDATA_TABLEHash:int = SAVE.CurrentMap.MAPDATA_TABLE.hash()
	SAVE.CurrentMap = null
	assert_true(SAVE.CM_load_current(SAVE_NAME), 
		"Loading failed.")
	assert_true(MAPDATA_TABLEHash == SAVE.CurrentMap.MAPDATA_TABLE.hash(),
		"Content of saved data doesnt match.")
	assert_true(SAVE.CM_delete(SAVE_NAME),
		"Deleting failed.")
	gut.p("Finished.")
