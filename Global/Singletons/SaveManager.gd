### ----------------------------------------------------
### Singleton handles all save management
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
### VARIABLES
### ----------------------------------------------------

const MAP_FOLDER := "res://Resources/SavedMaps/"
const SAV_FOLDER := "res://Resources/SavedSaves/"

var _CurrentMap:SQLSave = null
var _CurrentSav:SQLSave = null

### ----------------------------------------------------
### FUNCTIONS
### ----------------------------------------------------


func _create_empty_save(MapName:String, folderPath:String, TileMaps:Array) -> bool:
	var sqlsave := SQLSave.new(MapName, folderPath)
	return sqlsave.create_new_save(TileMaps)

func _load_map(MapName:String, TileMaps:Array) -> bool:
	var mapPath := MAP_FOLDER + MapName + ".db"
	if(not LibK.Files.file_exist(mapPath)):
		Logger.logErr(["Map doesnt exist: ", mapPath], get_stack())
		return false
	
	var isOK := true
	_CurrentMap = SQLSave.new(MapName, MAP_FOLDER)
	isOK = _CurrentMap.initialize() and isOK
	isOK = _CurrentMap.check_compatible(TileMaps) and isOK
	return isOK

func load_sav(SaveName:String, MapName:String, TileMaps:Array) -> bool:
	var isOK := _load_map(MapName, TileMaps)
	var savPath := SAV_FOLDER + SaveName + ".db"
	
	if(not isOK): return isOK
	if(not LibK.Files.file_exist(savPath)):
		Logger.logErr(["Save doesnt exist: ", savPath], get_stack())
		return false
	
	_CurrentSav = SQLSave.new(SaveName, SAV_FOLDER)
	isOK = _CurrentSav.initialize() and isOK
	isOK = _CurrentSav.check_compatible(TileMaps) and isOK
	return isOK

# Leave saveName empty if you want to overwrite save
func save_sav(SaveName:String) -> bool:
	return _CurrentSav.save_to_sqlDB(SAV_FOLDER + SaveName + ".db")

# Leave MapName empty if you want to overwrite map
func _save_map(MapName:String = "") -> bool:
	return _CurrentMap.save_to_sqlDB(MAP_FOLDER + MapName + ".db")

### ----------------------------------------------------
### Set / get / Remove
### ----------------------------------------------------


# Wrapper function, sets tile in _CurrentSav
func set_TileData_on(posV3:Vector3, tileData:TileData) -> bool:
	return _CurrentSav.set_TileData_on(posV3, tileData)

# Wrapper function, checks if tile was edited in _CurrentSav, if not get tile from _CurrentMap
func get_TileData_on(posV3:Vector3) -> TileData:
	var savResult := _CurrentSav.get_TileData_on(posV3)
	if(savResult.IDDict.empty()): return _CurrentMap.get_TileData_on(posV3)
	return savResult

# Wrapper function, remove tile in _CurrentSav
func remove_TileData_on(TSName:String, posV3:Vector3) -> bool:
	return _CurrentSav.remove_TileData_on(TSName, posV3)

# Wrapper function, checks if tile was edited in _CurrentSav, if not get tile from _CurrentMap
func get_TileData_on_chunk(chunkPosV3:Vector3, chunkSize:int) -> Dictionary:
	var savResult := _CurrentSav.get_TileData_on_chunk(chunkPosV3, chunkSize)
	var mapResult := _CurrentMap.get_TileData_on_chunk(chunkPosV3, chunkSize)
	for posV3 in savResult:
		if(savResult[posV3].IDDict.empty()): savResult[posV3] = mapResult[posV3]
	return savResult
