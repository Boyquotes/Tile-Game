### ----------------------------------------------------
### Class is used as library for custom data types and classes functions
### ----------------------------------------------------

extends Script
class_name LibCustom

### ----------------------------------------------------
# MapSaveData
### ----------------------------------------------------


# Loads a MapSaveData resource from a given path, returns null on fail
static func load_MapSaveData_resource(mapPath:String, TileMaps:Array) -> MapSaveData:
	if(not LibK.Files.file_exist(mapPath)):
		Logger.logErr(["MapSaveData path doesnt exist: ", mapPath], get_stack())
		return null

	var TempRef = ResourceLoader.load(mapPath, "", true)
	if(not TempRef is MapSaveData):
		Logger.logErr(["Tried to load resource of invalid type: ", mapPath], get_stack())
		return null

	if(not TempRef.check_compatible(TileMaps)):
		Logger.logErr(["Failed to load MapSaveData, tilemaps incopatible: ", mapPath], get_stack())
		return null

	return TempRef

# Function to create an empty map
static func create_MapSaveData_resource(TileMaps:Array, mapName:String) -> MapSaveData:
	var NewMap := MapSaveData.new()
	NewMap.create_new(TileMaps)
	NewMap.MapName = mapName
	return NewMap

### ----------------------------------------------------
# GameSave
### ----------------------------------------------------


# Loads a GameSave resource from a given path, returns null on fail
static func load_GameSave_resource(savePath:String, TileMaps:Array) -> GameSave:
	if(not LibK.Files.file_exist(savePath)):
		Logger.logErr(["GameSave doesnt exist: ", savePath], get_stack())
		return null
	
	var TempRef = ResourceLoader.load(savePath, "", true)
	if(not TempRef is GameSave):
		Logger.logErr(["Tried to load resource of invalid type: ", savePath], get_stack())
		return null
	
	if(not TempRef.init_save(TileMaps)):
		Logger.logErr(["Failed to load GameSave, tilemaps incopatible: ", savePath], get_stack())
		return null

	return TempRef


### ----------------------------------------------------
# General for resources
### ----------------------------------------------------


# Saves custom resource (compresses)
static func save_custom_resource(res:Resource, path:String, resType:String = "UNSPECIFIED") -> bool:
	var result := ResourceSaver.save(path, res, ResourceSaver.FLAG_COMPRESS)
	var isOK = (result == OK)
	if(isOK):  Logger.logMS(["Resource saved successfully: ", path, ", type: ", resType])
	if(!isOK): Logger.logErr(["Failed to save resource: ", path, ", type: ", resType, ", err: ", result], get_stack())
	return isOK
