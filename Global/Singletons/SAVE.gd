### ----------------------------------------------------
### Manages saves
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var CurrentSave:SaveData
var saveFolderDir:String = "res://Resources/SaveData/SavedMaps/"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func set_blank_save(TileMaps:Array) -> void:
	CurrentSave = SaveData.new()
	CurrentSave.create_new(TileMaps)
	Logger.logMS(["Set blank save."])


func save_CurrentSave(saveName:String = "") -> bool:
	if saveName != "": CurrentSave.SaveName = saveName
	
	var path:String = saveFolderDir + CurrentSave.SaveName + ".res"
	var result := ResourceSaver.save(path, CurrentSave, ResourceSaver.FLAG_COMPRESS)
	Logger.logMS(["Saved: ", CurrentSave.SaveName, " ",result])
	return (result == OK)


func load_CurrentSave(SaveName:String) -> bool:
	var saveFilePath:String = saveFolderDir + SaveName + ".res"
	if not LibK.Files.file_exist(saveFilePath):
		Logger.logErr(["Save called: ", SaveName, " doesn't exist!"], get_stack())
		return false
	
	var SD = ResourceLoader.load(saveFilePath)
	if SD is SaveData:
		CurrentSave = null
		CurrentSave = SD
		Logger.logMS(["Loaded: ", CurrentSave.SaveName])
		return true
	
	Logger.logErr(["Loading failed! Resource is not SaveData type."], get_stack())
	return false


func delete_save(SaveName:String) -> bool:
	var saveFilePath:String = saveFolderDir + SaveName + ".res"
	var result = LibK.Files.delete_file(saveFilePath)
	if result != OK:
		Logger.logErr(["Could not delete file: ", saveFilePath], get_stack())
		return false
	
	Logger.logMS(["Deleted file: ", saveFilePath])
	return true
### ----------------------------------------------------
