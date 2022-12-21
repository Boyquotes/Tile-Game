### ----------------------------------------------------
### Base class for every entity
### ----------------------------------------------------
extends Node2D
class_name EntityBase

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

### Position
var elevationLevel:int = 0
var mapPosition:Vector2 = Vector2(0,0) setget _set_map_position

### Set by SimulationManager
onready var Data = {
	isReady 		= false,
	SimRequest 		= null,
	mapXYBoundaries = [],
}

onready var Init = {
	isSimulated = false,
	scenePath 	= "Not Set",
}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### ----------------------------------------------------
# Setget
### ----------------------------------------------------

func _set_map_position(pos):
	if not Data.isReady:
		Logger.logErr(["Entity: ", get_name(), ", is not ready!"], get_stack())
		return
	
	var minx = Data.mapXYBoundaries[0][0]
	var maxx = Data.mapXYBoundaries[0][1]
	var miny = Data.mapXYBoundaries[1][0]
	var maxy = Data.mapXYBoundaries[1][1]
	
	pos[0] = clamp(pos[0],minx,maxx)
	pos[1] = clamp(pos[1],miny,maxy)
	
	mapPosition = pos
	
	# Map position is relative to tiles, so it does not depend on tile size
	#set_global_position(mapPosition*TILEDATA.WALL_PIXEL)
### ----------------------------------------------------


### ----------------------------------------------------
# Save / Load
### ----------------------------------------------------

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
### ----------------------------------------------------
