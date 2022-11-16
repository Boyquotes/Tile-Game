### ----------------------------------------------------
### Unit test for MapManager
### ----------------------------------------------------
extends UnitTestBase

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# Unit test for basic save interactions
func new_save_test() -> void:
	var TileMaps:Array = TestedNode.get_children()
	
	# Create new SaveData
	var testSD = SaveDataRes.new()
	TestedNode.SaveData = testSD
	TestedNode.SaveData.initialize(TileMaps)
	
	var MapDataShort = TestedNode.SaveData.MapData
	
	# Iterate through every possible tile to add
	var yCord:int = 0
	for tileMap in TileMaps:
		var tileNames:Array = LibK.TS.get_tile_names(tileMap.tile_set)
		var TMName:String = tileMap.get_name()
		
		for tileName in tileNames:
			var packedPos:Array = [Vector2(0,yCord),0]
			MapDataShort.set_TData_on(TMName,packedPos,tileName)
			
			var result = MapDataShort.get_TData_on(TMName,packedPos)
			errors += UnitTestLib.asserteq(tileName,result["tileName"],"new_save_test")
			yCord += 1


# Unit test for save/load functions
func save_load_test() -> void:
	new_save_test() # run to make sure save is not empty
	var TDataLogbck = TestedNode.SaveData.MapData.TDataLog
	var TDatabck = TestedNode.SaveData.MapData.TData
	TestedNode.SaveData.SaveName = "Test"
	
	# Save data from previous test
	TestedNode.save_current_SaveData()
	
	# Clear current map data
	TestedNode.SaveData = null
	
	# Save data from previous test
	TestedNode.load_SaveData("Test")
	
	#Test loaded save
	var MDShort = TestedNode.SaveData.MapData
	for tsName in MDShort.TData:
		errors += UnitTestLib.asserteqDict(MDShort.TData[tsName],TDatabck[tsName],"save_load_test")
	errors += UnitTestLib.asserteqDict(MDShort.TDataLog,TDataLogbck,"save_load_test")
	
	Logger.logMS(["Logback: ", TDataLogbck])
	
	# Cleanup
	TestedNode.delete_save("Test")
