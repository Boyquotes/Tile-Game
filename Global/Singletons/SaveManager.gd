### ----------------------------------------------------
### Manages currently loaded save and all actions regarding saves
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# Map directory
const MAP_FOLDER_DIR := "res://Resources/SavedMaps/"

# Save direcotry
const SAV_FOLDER_DIR := "res://Temp/"

# Currently loaded save
var _CurrentSave setget _set_CurrentSave
func _set_CurrentSave(TempRef) -> bool:
	if(TempRef is GameSave or TempRef is MapSaveData):
		_CurrentSave = TempRef
		Logger.logMS(["Changed _CurrentSave: " + str(TempRef)])
		return true
	return false

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


# Creates a new empty CurrentSave
# Map for save should exist
func set_new_CurrentSave(TileMaps:Array, mapName:String, saveName:String) -> bool:
	var TempRef := GameSave.new()
	if(not TempRef.create_new_save(TileMaps, mapName, saveName)): return false
	_CurrentSave = _set_CurrentSave(TempRef)
	return true

# Loads CurrentSave from save directory
# Map for save should exist
func load_CurrentSave(TileMaps:Array, saveName:String) -> bool:
	var savePath = GameSave.SAV_FOLDER_DIR + saveName + ".res"
	var TempRef = LibCustom.load_GameSave_resource(savePath, TileMaps)
	if(not TempRef == null): 
		Logger.logErr(["failed to load CurrentSave: ", saveName, " ", savePath], get_stack())
		return false
	_CurrentSave = _set_CurrentSave(TempRef)
	return true

# Saves CurrentSave to save directory
# if SaveName is not specified CurrenSave.SaveName is used
func save_CurrentSave(saveName:String = "") -> bool:
	if(saveName == ""): _CurrentSave.SaveName = saveName
	var savePath = SAV_FOLDER_DIR + _CurrentSave.SaveName + ".res"
	return LibCustom.save_custom_resource(_CurrentSave, savePath, "GameSave")

### ----------------------------------------------------
# Get from save
### ----------------------------------------------------


# Interface function for _CurrentSave to get TileData
func get_TileData_on(TSName:String, posV3:Vector3) -> TileData:
	return _CurrentSave.get_tile_on(TSName, posV3)

# Interface function for _CurrentSave to remove TileData
func remove_TileData_on(TSName:String, posV3:Vector3) -> bool:
	return _CurrentSave.remove_tile_on(TSName, posV3)

# Interface function for _CurrentSave to set TileData
func set_TileData_on(TSName:String, posV3:Vector3, tileData:TileData) -> bool:
	return _CurrentSave.set_tile_on(TSName, posV3, tileData)
