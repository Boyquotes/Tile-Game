### ----------------------------------------------------
### Unit test for MapManager
### ----------------------------------------------------
extends GutTestLOG

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const _MM = preload("res://Scenes/SimulationManager/MapManager/MapManager.tscn")
var MapManager:Node = null

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func before_each():
	MapManager = autoqfree(_MM.instance())
	add_child(MapManager)

### ----------------------------------------------------
# UnitTests
### ----------------------------------------------------

func test_MapManager_functions():
	LOG_GUT(["update_visable_map test"])
	var PositionsV3 = LibK.Vectors.vec3_get_square(Vector3(0,0,0), 1, true)
	MapManager.update_visable_map(PositionsV3)
	
	assert_true(MapManager.LoadedChunks==PositionsV3, "Chunks should be loaded")
	gut.p(MapManager.LoadedChunks)

### ----------------------------------------------------
