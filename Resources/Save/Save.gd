### ----------------------------------------------------
# Stores data regarding save
### ----------------------------------------------------

extends Resource
class_name Save

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const MAP_FOLDER_DIR := "res://Resources/Save/SavedMaps/"
const SAV_FOLDER_DIR := "res://Temp/"

# Name of this save
export var SaveName := "Default"

# Map that is currently selected from MapList
var _MapSave:MapSaveData

# Map template, not meant to be changed
var _MapTemplate:MapSaveData

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


func init_save(TileMaps:Array, mapName:String) -> bool:
	var isOK := true
	isOK = isOK and _load_MapTemplate(TileMaps, mapName)
	if(not isOK): return isOK
	isOK = isOK and _load_MapSave(TileMaps, mapName)
	return isOK

### ---------------------------------------------------
# Util
### ----------------------------------------------------

# Loads map template
func _load_MapTemplate(TileMaps:Array, mapName:String) -> bool:
	var mapPath := MAP_FOLDER_DIR + mapName + ".res"
	var TempRef = _load_map_resource(mapPath, TileMaps)
	if(TempRef == null):
		Logger.logErr(["failed to load MapTemplate: ", mapName], get_stack())
		return false
	
	_MapTemplate = null
	_MapTemplate = TempRef
	
	Logger.logMS(["Loaded MapTemplate successfully: ", mapName])
	return true


func _load_MapSave(TileMaps:Array, mapName:String) -> bool:
	var mapPath := SAV_FOLDER_DIR + SaveName + ".res"
	var TempRef = _load_map_resource(mapPath, TileMaps)
	if(TempRef == null):
		Logger.logErr(["Failed to load CurrentMap: ", mapName], get_stack())
		return false
	
	if(not TempRef.MapName == mapName):
		Logger.logErr(["MapSave MapName doesnt match MapTemplate: ", TempRef.MapName, " ", mapName], get_stack())
		return false

	_MapSave = null
	_MapSave = TempRef
	
	Logger.logMS(["Loaded CurrentMap successfully: ", mapName])
	return true


static func _load_map_resource(mapPath:String, TileMaps:Array) -> MapSaveData:
	if(not LibK.Files.file_exist(mapPath)):
		Logger.logErr(["Map path doesnt exist: ", mapPath], get_stack())
		return null

	var TempRef = ResourceLoader.load(mapPath)
	if(not TempRef is MapSaveData):
		Logger.logErr(["Tried to load resource of invalid type: ", mapPath], get_stack())
		return null

	if(not TempRef.check_compatible(TileMaps)):
		Logger.logErr(["Failed to load MapSaveData, tilemaps incopatible: ", mapPath], get_stack())
		return null
	return TempRef


static func _create_new_MapSave(TileMaps:Array, mapPath:String, mapName:String) -> bool:
	var NewMap := MapSaveData.new()
	NewMap.create_new(TileMaps)
	NewMap.MapName = mapName

	var result := ResourceSaver.save(mapPath, NewMap, ResourceSaver.FLAG_COMPRESS)
	var isOK = (result == OK)
	if(isOK):  Logger.logMS(["Created new map successfully: ", mapName])
	if(!isOK): Logger.logErr(["Failed to create new map: ", mapName, " ", mapPath, " ", result], get_stack())
	return isOK
