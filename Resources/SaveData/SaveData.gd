### ----------------------------------------------------
### Save resource
### ----------------------------------------------------

extends Resource
class_name SaveData

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

export(String) var SaveName = "Unnamed"

# Holds map data
export var TSData := Dictionary() # { TSName:{PackedPos:TileData} }

# Holds TileSet data (setup when creating a new save) 
export var TS_CONTROL := Dictionary() # { TSName:{tileID:tileName} }

### ----------------------------------------------------
# Functions
### ----------------------------------------------------

# Check if the current tilemaps are compatible with TS_CONTROL tilemaps
func check_compatible(TileMaps:Array) -> bool:
	var isOK := true
	for tileMap in TileMaps:
		var TSName:String = tileMap.get_name()
		var tileSet:TileSet = tileMap.tile_set
		
		if not TS_CONTROL.has(TSName):
			Logger.logErr(["TS_CONTROL is missing TSName: " + TSName], get_stack())
			isOK = false
			continue
		
		var tileNamesIDs = LibK.TS.get_tile_names_and_IDs(tileSet)
		for index in range(tileNamesIDs.size()):
			var tileName:String = tileNamesIDs[index][0]
			var tileID:int = tileNamesIDs[index][1]
			if not TS_CONTROL[TSName].has(tileID):
				Logger.logErr(["TS_CONTROL is missing tileID: ", tileID], get_stack())
				isOK = false
				continue
			
			if TS_CONTROL[TSName][tileID] != tileName:
				Logger.logErr(["TileName doesn't match for tileID: ", tileID, " ", tileName],
					get_stack())
				isOK = false
				continue
	
	return isOK


func create_new(TileMaps:Array):
	for tileMap in TileMaps:
		var TSName:String = tileMap.get_name()
		var tileSet:TileSet = tileMap.tile_set
		
		TS_CONTROL[TSName] = {}
		TSData[TSName] = {}
		
		var tileNamesIDs = LibK.TS.get_tile_names_and_IDs(tileSet)
		for index in range(tileNamesIDs.size()):
			TS_CONTROL[TSName][tileNamesIDs[index][1]] = tileNamesIDs[index][0]

### ----------------------------------------------------
# Map - Set / Get / Remove
### ----------------------------------------------------
func set_tile_on(TSName:String, posV3:Vector3, tileData:TileData) -> bool:
	if not TS_CONTROL.has(TSName):
		Logger.logErr(["TSName doesnt exist in available TileSets: " + TSName], get_stack())
		return false
	
	if not TS_CONTROL[TSName].has(tileData.tileID):
		Logger.logErr(["tileID doesnt exist in available TileSets: " + str(tileData.tileID)], get_stack())
		return false
	
	if not TSData.has(TSName): TSData[TSName] = {}
	TSData[TSName][str(posV3)] = str(tileData)
	
	return true


func get_tile_on(TSName:String, posV3:Vector3) -> TileData:
	if not TS_CONTROL.has(TSName):
		Logger.logErr(["TSName doesnt exist in available TileSets: " + TSName], get_stack())
		return TileData.new()
	
	if not TSData.has(TSName):
		Logger.logErr(["TSName doesnt exist in TSData: " + TSName], get_stack())
		return TileData.new()
	
	if not TSData[TSName].has(str(posV3)):
		return TileData.new()
	
	var tileData := TileData.new()
	return tileData.from_str(TSData[TSName][str(posV3)])


func remove_tile_on(TSName:String, posV3:Vector3) -> bool:
	if not TS_CONTROL.has(TSName):
		Logger.logErr(["TSName doesnt exist in available TileSets: " + TSName], get_stack())
		return false
	
	if not TSData.has(TSName):
		Logger.logErr(["TSName doesnt exist in TSData: " + TSName], get_stack())
		return false
	
	# if not TSData[TSName].has(str(posV3)): return false
	TSData[TSName].erase(str(posV3))
	return true
### ----------------------------------------------------
