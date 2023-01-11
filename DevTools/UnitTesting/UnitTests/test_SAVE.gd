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
			assert_true(SAVE.CurrentSave.set_tile_on(TMName, posV3, tileData),
				"Unable to set tile on: " + TMName + " " + str(posV3))
			assert_eq(str(tileData), str(SAVE.CurrentSave.get_tile_on(TMName, posV3)),
				"tileData should match")
			yCord += 1
	
	LOG_GUT("save and load test")
	assert_true(SAVE.save_CurrentSave(SAVE_NAME),
		"Saving failed.")
	var TSDataHash:int = SAVE.CurrentSave.TSData.hash()
	SAVE.CurrentSave = null
	assert_true(SAVE.load_CurrentSave(SAVE_NAME), 
		"Loading failed.")
	assert_true(TSDataHash == SAVE.CurrentSave.TSData.hash(),
		"Content of saved data doesnt match.")
	assert_true(SAVE.delete_save(SAVE_NAME),
		"Deleting failed.")
	gut.p("Finished.")
