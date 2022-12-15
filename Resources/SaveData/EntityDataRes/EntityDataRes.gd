### ----------------------------------------------------
### Resource is used as a save file for the map.
### ----------------------------------------------------
extends Resource
class_name EntityDataRes

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# !IMPORTANT:
# !Do not access these dicts directly!
# !They are designed to be accessed via SET/GET functions

# Simulated Entities
export(Dictionary) var EDataSim = {}   # {packedPos:data}

# Not simulated Entities
export(Dictionary) var EDataNoSim = {} # {packedPos:data}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# INIT #
func initialize() -> bool:
	if not _check_data_compatibility():
		Logger.logMS(["Cannot initialize EDataRes, data is incompatible"])
		return false
	return true


# Checks if loaded data is compatible with current standard
# TODO: if data is missing key fill it with null so updates dont break the game
func _check_data_compatibility():
	for packedPos in EDataSim:
		if not _check_pack_data(EDataSim[packedPos]):
			return false
	
	for packedPos in EDataNoSim:
		if not _check_pack_data(EDataSim[packedPos]):
			return false
	
	return true


# GET #
func get_EDataNoSim_on(packedPos:Array, loadEntity:bool = false) -> Dictionary:
	if not EDataNoSim.has(packedPos):
		return {}
	
	# |NOTE:
	# |This makes sure the same entity is not loaded multiple times
	# |Before saving make sure to save all entities data 
	var data = EDataNoSim[packedPos]
	if loadEntity:
		EDataNoSim.erase(packedPos)
		Logger.logMS(["Loaded not simulated entity on pos: ",packedPos,", from save."])
	
	return data


func get_all_EDataSim(loadEntity:bool = false) -> Dictionary:
	var data:Dictionary = {} 
	for packedPos in EDataSim:
		data[packedPos] = EDataSim[packedPos] # Copy the dict
	
	# |NOTE:
	# |This makes sure the same entity is not loaded multiple times
	# |Before saving make sure to save all entities data 
	if loadEntity:
		Logger.logMS(["Loaded all simulated entities from save."])
		EDataSim = {}
	
	return data

# SET #
func set_EDataSim_on(packedPos:Array,data:Dictionary):
	if not _check_pack_data(data):
		Logger.LogMS(["Can't set Edata on: ", packedPos], true)
		return
	
	EDataSim[packedPos] = data


func set_EDataNoSim_on(packedPos:Array,data:Dictionary):
	if not _check_pack_data(data):
		Logger.LogMS(["Can't set Edata on, data not compatible: ", packedPos], true)
		return
	
	EDataSim[packedPos] = data


# DATA PACKING #
# List of all must have keys for an enemy
enum EDV {ScenePath} 

# Universal packing of data (for EData)
func pack_data(ScenePath:String) -> Dictionary:
	var data = {}
	for key in EDV:
		data[key] = null
	
	data[EDV.keys()[EDV.ScenePath]] = ScenePath
	return data


func _check_pack_data(data:Dictionary):
	var edvKeys = EDV.keys()
	for key in data:
		if not edvKeys.has(key):
			Logger.logErr(["Packed data for EData missing key: ", key], get_stack())
			return false
	
	return true
