### ----------------------------------------------------
### Unit test for SimulationManager
### ----------------------------------------------------
extends UnitTestBase

var MapCreator:Script = preload("res://DevTools/MapCreator/MapCreator.gd")
const saveName = "SimManagerTest"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func check_chunks():
	var MapManager = TestedNode.get_node("MapManager")
	
	# Generate a map with the player and check if chunks are properly generated
	MapCreator.generate_map_template(saveName)
	
	# Load saved map to MapManager
	errors += UnitTestLib.assertT(TestedNode.start_simulation(saveName),"check_chunks","start_simulation")
	TestedNode.update_simulation()
	
	# Rendered chunks for 1 entity
	var chunkArythmetic = 2 * (TestedNode.SIM_RANGE+1) - 1         # (2*(n+1)-1)
	var predictedChunkCount = pow(chunkArythmetic,chunkArythmetic) # square
	errors += UnitTestLib.asserteq(predictedChunkCount,TestedNode.SimulatedChunks.size(),"check_chunks")
	
	# Cleanup
	MapManager.delete_save(saveName)
