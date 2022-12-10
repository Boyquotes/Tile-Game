### ----------------------------------------------------
### Unit test for MapManager
### ----------------------------------------------------
extends GutTestLOG

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const MapManagerScene = preload("res://Scenes/SimulationManager/MapManager/MapManager.tscn")
var MapManager:Node = null

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func before_all():
	MapManager = autoqfree(MapManagerScene.instance())
	add_child(MapManager)


func test_save_and_load() -> void:
	MapManager.set_blank_save()
	var MapDataShort = MapManager.SaveData.MapData
	
	LOG_GUT("Iterate through every possible tile")
	var yCord:int = 0
	for tileMap in MapManager.get_tilemaps():
		var TMName:String = tileMap.get_name()
		
		for tileName in LibK.TS.get_tile_names(tileMap.tile_set):
			var packedPos:Array = [Vector2(0,yCord),0]
			
			# Set Data on cord
			MapDataShort.set_TData_on(TMName,packedPos,tileName)
			
			# Load Data on cord anc check
			assert_eq(tileName, MapDataShort.get_TData_on(TMName,packedPos)["tileName"], "Tiles should match")
			yCord += 1
	
	LOG_GUT("save and load test", true)
	
	var TDataLogbck = MapDataShort.TDataLog
	var TDatabck = MapDataShort.TData
	
	MapManager.SaveData.SaveName = "Test"
	MapManager.save_current_SaveData()
	MapManager.SaveData = null
	MapManager.load_SaveData("Test")
	
	#Test loaded save
	var MDShort = MapManager.SaveData.MapData
	for tsName in MDShort.TData:
		assert_eq_deep(MDShort.TData[tsName],TDatabck[tsName])
	assert_eq_deep(MDShort.TDataLog,TDataLogbck)
	
	Logger.logMS(["Logback: ", TDataLogbck])
	
	# Cleanup
	MapManager.delete_save("Test")

