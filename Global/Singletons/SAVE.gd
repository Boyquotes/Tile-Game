### ----------------------------------------------------
### Manages saves
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const CM_FOLDER_DIR := "res://Resources/SaveData/SavedMaps/"
const CS_FOLDER_DIR := "res://Resources/SaveData/SavedSaves/"

# CurrentMap is used as a map template for the current save
var CurrentMap:SaveData setget _s_cm
func _s_cm(_s): return

# CurrentSave is everything that player changed in the map
# Direct access only via special functions, never directly
var CurrentSave:SaveData setget _s_cs
func _s_cs(_s): return

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### ----------------------------------------------------
# Set CS
### ----------------------------------------------------
func CS_set_blank(TileMaps:Array) -> void:
	CurrentSave = SaveData.new()
	CurrentSave.create_new(TileMaps)
	Logger.logMS(["CS set to blank."])


func CS_save_current(saveName:String = "") -> bool:
	if saveName != "": CurrentSave.SaveName = saveName
	var path:String = CS_FOLDER_DIR + CurrentSave.SaveName + ".res"
	var result := ResourceSaver.save(path, CurrentSave, ResourceSaver.FLAG_COMPRESS)
	Logger.logMS(["Saved CS: ", CurrentSave.SaveName, " ", result])
	return (result == OK)


func CS_load_current(SaveName:String) -> bool:
	var path:String = CS_FOLDER_DIR + SaveName + ".res"
	if not LibK.Files.file_exist(path):
		Logger.logErr(["CS Save called: ", SaveName, " doesn't exist!"], get_stack())
		return false
		
	CurrentSave = null
	var SD = ResourceLoader.load(path)
	if SD is SaveData:
		CurrentSave = SD
		Logger.logMS(["Loaded CS: ", CurrentSave.SaveName])
		return true
	
	Logger.logErr(["Loading CS failed! Resource is not SaveData type."], get_stack())
	return false


func CS_delete(SaveName:String) -> bool:
	var path:String = CS_FOLDER_DIR + SaveName + ".res"
	var result = LibK.Files.delete_file(path)
	if result != OK:
		Logger.logErr(["Could not delete CS file: ", path], get_stack())
		return false
	
	Logger.logMS(["Deleted CS file: ", path])
	return true
### ----------------------------------------------------


### ----------------------------------------------------
# Set CM
### ----------------------------------------------------
func CM_set_blank(TileMaps:Array) -> void:
	CurrentMap = SaveData.new()
	CurrentMap.create_new(TileMaps)
	Logger.logMS(["CM set to blank."])


func CM_save_current(saveName:String = "") -> bool:
	if saveName != "": CurrentMap.SaveName = saveName
	var path:String = CM_FOLDER_DIR + CurrentMap.SaveName + ".res"
	var result := ResourceSaver.save(path, CurrentMap, ResourceSaver.FLAG_COMPRESS)
	Logger.logMS(["Saved CM: ", CurrentMap.SaveName, " ", result])
	return (result == OK)


func CM_load_current(SaveName:String) -> bool:
	var path:String = CM_FOLDER_DIR + SaveName + ".res"
	if not LibK.Files.file_exist(path):
		Logger.logErr(["CM Save called: ", SaveName, " doesn't exist!"], get_stack())
		return false
		
	CurrentMap = null
	var SD = ResourceLoader.load(path)
	if SD is SaveData:
		CurrentMap = SD
		Logger.logMS(["Loaded CM: ", CurrentMap.SaveName])
		return true
	
	Logger.logErr(["Loading CM failed! Resource is not SaveData type."], get_stack())
	return false


func CM_delete(SaveName:String) -> bool:
	var path:String = CM_FOLDER_DIR + SaveName + ".res"
	var result = LibK.Files.delete_file(path)
	if result != OK:
		Logger.logErr(["Could not delete CM file: ", path], get_stack())
		return false
	
	Logger.logMS(["Deleted CM file: ", path])
	return true
### ----------------------------------------------------
