### ----------------------------------------------------
### Base class for MapManager
### Handles all map load/save interactions
### ----------------------------------------------------
extends Node2D
class_name SaveManager

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var SaveData:SaveDataRes
export (String) var SaveFolderPath = "res://Resources/SaveData/SavedMaps/"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### SAVE MANAGEMENT ###
func set_blank_save():
	SaveData = SaveDataRes.new()
	var _result = SaveData.initialize(get_tilemaps())
	Logger.logMS(["Set blank save to MapManager."])


func save_current_SaveData() -> bool:
	var path = SaveFolderPath + SaveData.SaveName + ".res"
	var result = ResourceSaver.save(path,SaveData,ResourceSaver.FLAG_COMPRESS)
	
	Logger.logMS(["Saved: ", SaveData.SaveName, " ",result])
	
	return (result == 0)


func load_SaveData(SaveName:String) -> bool:
	if not LibK.Files.file_exist(SaveFolderPath + SaveName + ".res"):
		Logger.logMS(["Save called: ", SaveName, " doesn't exist!"], true)
		return false
	
	set_blank_save()
	var saveFilePath:String = SaveFolderPath + SaveName + ".res"
	
	var SD = ResourceLoader.load(saveFilePath)
	if SD is SaveDataRes:
		SD.initialize(get_tilemaps())
		SaveData = SD
		Logger.logMS(["Loaded: ", SaveData.SaveName])
		return true
	
	Logger.logMS(["Loading failed! Resource is not SaveDataRes type."], true)
	return false


func delete_save(SaveName:String) -> bool:
	var saveFilePath:String = SaveFolderPath + SaveName + ".res"
	
	var dir = Directory.new()
	var result = dir.remove(saveFilePath)
	if not result == 0:
		Logger.logMS(["Could not delete file: ", SaveName], true)
		return false
	
	Logger.logMS(["Deleted file: ", SaveName])
	return true


# UTILITY #
# Returns all tilemap children of the node
func get_tilemaps() -> Array:
	var TileMaps:Array = []
	
	for node in get_children():
		if node is TileMap:
			TileMaps.append(node)
	
	return TileMaps
