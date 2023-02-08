### ----------------------------------------------------
# Stores data regarding save
### ----------------------------------------------------

extends MapSaveData
class_name GameSave

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# Name of this save
export var SaveName := "Default"

# Map template, not meant to be changed nor accessed outside of this script or editor
var _MapTemplate:MapSaveData

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


# Util function to create a new save correctly
func create_new_save(TileMaps:Array, mapName:String, saveName:String) -> bool:
	create_new(TileMaps)
	MapName = mapName
	SaveName = saveName
	return init_save(TileMaps)

# Call when loading a save resource
func init_save(TileMaps:Array) -> bool:
	var isOK := true

	# Load map and check if its compatible with current tileset
	isOK = isOK and _load_MapTemplate(TileMaps)
	if(not isOK): return isOK

	# Check if save data is compatible with tileset
	isOK = isOK and check_compatible(TileMaps)
	
	return isOK

# Get tile overwrite
# First check if tile was edited, if not check map template
func get_tile_on(TSName:String, posV3:Vector3) -> TileData:
	if not TS_CONTROL.has(TSName):
		Logger.logErr(["TSName doesnt exist in available TileSets: " + TSName], get_stack())
		return TileData.new()
	
	if not TSData.has(TSName):
		Logger.logErr(["TSName doesnt exist in TSData: " + TSName], get_stack())
		return TileData.new()
	
	if not TSData[TSName].has(str(posV3)):
		return _MapTemplate.get_tile_on(TSName, posV3)
	
	var tileData := TileData.new()
	return tileData.from_str(TSData[TSName][str(posV3)])

# Loads MapTemplate from map directory (Not using LibCustom because cyclic dependency)
func _load_MapTemplate(TileMaps:Array) -> bool:
	var mapPath:String = SaveManager.MAP_FOLDER_DIR + MapName + ".res"
	if(not LibK.Files.file_exist(mapPath)):
		Logger.logErr(["MapSaveData path doesnt exist: ", mapPath], get_stack())
		return false

	var TempRef = ResourceLoader.load(mapPath)
	if(not TempRef is MapSaveData):
		Logger.logErr(["Tried to load resource of invalid type: ", mapPath], get_stack())
		return false

	if(not TempRef.check_compatible(TileMaps)):
		Logger.logErr(["Failed to load MapSaveData, tilemaps incopatible: ", mapPath], get_stack())
		return false
	
	_MapTemplate = null
	_MapTemplate = TempRef
	
	Logger.logMS(["Loaded MapTemplate successfully: ", MapName])
	return true
