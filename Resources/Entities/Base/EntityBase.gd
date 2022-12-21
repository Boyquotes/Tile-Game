### ----------------------------------------------------
### Base class for every entity
### ----------------------------------------------------
extends Node2D
class_name EntityBase

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

### Set by SimulationManager
var isReady:bool = false
var SimRequest:Node2D = null
var mapXYBoundaries:Array = []

### Position
var elevationLevel:int = 0
var mapPosition:Vector2 = Vector2(0,0) setget _set_map_position

### Simulation info
var isSimulated:bool = false
var scenePath:String = "Not Set"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### SETGET ###
func _set_map_position(pos):
	if not isReady:
		Logger.logErr(["Entity: ", get_name(), ", is not ready!"], get_stack())
		return
	
	var minx = mapXYBoundaries[0][0]
	var maxx = mapXYBoundaries[0][1]
	var miny = mapXYBoundaries[1][0]
	var maxy = mapXYBoundaries[1][1]
	
	pos[0] = clamp(pos[0],minx,maxx)
	pos[1] = clamp(pos[1],miny,maxy)
	
	mapPosition = pos
	
	# Map position is relative to tiles, so it does not depend on tile size
	#set_global_position(mapPosition*TILEDATA.WALL_PIXEL)


# SAVE/LOAD #
# Function that handles entity load from SaveData
func load_entity_data(EData:Dictionary, packedPos:Array):
	# Load position on the map
	mapPosition = packedPos[0]
	elevationLevel = packedPos[1]
	
	_load_entity_data_spec(EData)


# Specific load function for entity (can be overwritten)
func _load_entity_data_spec(_EData:Dictionary):
	Logger.logMS(["WARNING - Load function not specific, entity data could be lost: ", get_name()])


# Function that handles entity save in SaveData
func save_entity_data():
	_save_entity_data_spec()


# Specific save function for entity (can be overwritten)
func _save_entity_data_spec():
	Logger.logMS(["WARNING - Save function not specific, entity data could be lost: ", get_name()])
