### ----------------------------------------------------
### Save resource
### ----------------------------------------------------
extends Resource

class_name SaveDataRes

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

export(String) var SaveName = "Unnamed"
export (Resource) var MapData = MapDataRes.new()
export (Resource) var EntityData = EntityDataRes.new()

var isReady:bool = false

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### INIT ###
# Initialization of save (run when loaded save)
# Have to call that every time you want to load a map
func initialize(TileMaps:Array) -> bool:
	if TileMaps.size() == 0:
		Logger.logMs(["No TileMaps available!"], true)
		Logger.logMs(["Failed to initialize MapData!"], true)
		return false
	
	isReady = MapData.initialize(TileMaps)
	isReady = EntityData.initialize()
	return true
