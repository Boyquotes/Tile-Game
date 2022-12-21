### ----------------------------------------------------
### Decides what chunks of the map are meant to be simulated in the game
### ----------------------------------------------------
extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const SIM_RANGE = 1 # How far (chunks) world will generate 

var SimulatedEntities:Array # List of objects that require rendering the world around them (example: player)
# SimulatedEntities = [Entity,Entity2,...] <-- Entity is Node2D, by default player
 
var SimulatedChunks:Array # List of all simulated chunks
# SimulatedChunks = [[chunkPos,elevationLevel],...]

var GFObjectSet:bool = false
var GameFocusObject:Node2D # Focus of both camera and rendering tilemap
var GFObjectChunks:Array   # List of simulated chunks around focus entity

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### PUBLIC ###
func start_simulation(mapName:String) -> bool:
	var isOk:bool = true
	
	# Load save file
	isOk = $MapManager.load_SaveData(mapName)
	if not isOk:
		Logger.logErr(["Failed to start simulation (load_SaveData)."], get_stack())
		return isOk
	
	# Load simulated entities to the map
	var EDataSimCopy:Dictionary = $MapManager.SaveData.EntityData.get_all_EDataSim(true)
	isOk = $EntityManager.load_simulated_entities(EDataSimCopy)
	if not isOk:
		Logger.logErr(["Failed to start simulation (load_simulated_entities)."], get_stack())
		return isOk
	
	# For now its player by default on loading save
	isOk = set_GFObject($EntityManager.Player)
	
	return isOk


# Sets game focus object to be followed by the camera
# Chunks around this object are visually rendered to TileMaps
func set_GFObject(obj:Node2D) -> bool:
	if not obj is EntityBase:
		Logger.logMS(["Could not set new GameFocusObject: ", obj.get_name(),", invalid object type."])
		return false
	
	GameFocusObject = obj
	GFObjectSet = true
	Logger.logMS(["Set new GameFocusObject: ", obj.get_name()])
	return true


func update_simulation() -> bool:
	# Get chunks to simulate
	SimulatedEntities = $EntityManager.get_simulated_entities()
	_update_simulated_chunks()
	
	# Update visable map
	var GFObjectElevation:int = GameFocusObject.elevationLevel
	$MapManager.update_visable_map(GFObjectChunks,GFObjectElevation)
	
	# Update camera position
	$ViewCamera.update_camera_pos(GameFocusObject)
	
	return true


### PRIVATE ###
func _update_simulated_chunks():
	SimulatedChunks = []; GFObjectChunks = []
	
	for Entity in SimulatedEntities:
		var entityChunk = DATA.Map.GET_CHUNK_ON_POSITION(Entity.mapPosition)
		var chunkRange = LibK.Vectors.GET_POS_RANGE_V2(SIM_RANGE,entityChunk,false)
		var elevation = Entity.elevationLevel
		
		for elevationLevel in range(elevation-SIM_RANGE,elevation+SIM_RANGE+1):
			for chunkPos in chunkRange:
				SimulatedChunks.append([chunkPos,elevationLevel])
				
				# This takes care of getting chunks to render
				if Entity == GameFocusObject:
					GFObjectChunks.append([chunkPos,elevationLevel])
