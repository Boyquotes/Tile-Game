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

var TileMaps:Array = []  # Reference to all tilemaps

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _enter_tree() -> void:
	# Load all TileMaps
	for packed in LibK.Files.get_file_list_at_dir(DATA.TILEMAPS_DIR):
		var filePath:String = packed[0]
		var fileName:String = packed[1]
		var TMScene:PackedScene = load(filePath + "/" + fileName + ".tscn")
		var TMInstance = TMScene.instance()
		add_child(TMInstance)
	TileMaps = get_tilemaps()

### ----------------------------------------------------
# Save management
### ----------------------------------------------------
func set_blank_save():
	SaveData = SaveDataRes.new()
	var _result = SaveData.initialize(get_tilemaps())
	Logger.logMS(["Set blank save to MapManager."])


func save_current_SaveData() -> bool:
	var path = DATA.SAVE_FLODER_PATH + SaveData.SaveName + ".res"
	var result = ResourceSaver.save(path,SaveData,ResourceSaver.FLAG_COMPRESS)
	
	Logger.logMS(["Saved: ", SaveData.SaveName, " ",result])
	
	return (result == 0)


func load_SaveData(SaveName:String) -> bool:
	if not LibK.Files.file_exist(DATA.SAVE_FLODER_PATH + SaveName + ".res"):
		Logger.logErr(["Save called: ", SaveName, " doesn't exist!"], get_stack())
		return false
	
	set_blank_save()
	var saveFilePath:String = DATA.SAVE_FLODER_PATH + SaveName + ".res"
	
	var SD = ResourceLoader.load(saveFilePath)
	if SD is SaveDataRes:
		SD.initialize(get_tilemaps())
		SaveData = SD
		Logger.logMS(["Loaded: ", SaveData.SaveName])
		return true
	
	Logger.logErr(["Loading failed! Resource is not SaveDataRes type."], get_stack())
	return false


func delete_save(SaveName:String) -> bool:
	var saveFilePath:String = DATA.SAVE_FLODER_PATH + SaveName + ".res"
	
	var dir = Directory.new()
	var result = dir.remove(saveFilePath)
	if not result == 0:
		Logger.logErr(["Could not delete file: ", SaveName], get_stack())
		return false
	
	Logger.logMS(["Deleted file: ", SaveName])
	return true
### ----------------------------------------------------


### ----------------------------------------------------
# Utility
### ----------------------------------------------------

# Returns all tilemap children of the node
func get_tilemaps() -> Array:
	var TM:Array = []
	for node in get_children(): if node is TileMap: TM.append(node)
	return TM
### ----------------------------------------------------
