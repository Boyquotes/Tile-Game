### ----------------------------------------------------
### Resource is used as a save file for the map.
### ----------------------------------------------------
extends Resource
class_name MapDataRes

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

export(Dictionary) var TData = {}    # {TSName:{ [TilePos,elevation]:data }}
export(Dictionary) var TDataLog = {} # {[TileName,TSName]:TileID}

export(Array) var XYBoundaries = [[0,0],[0,0]] # [[minx,maxx],[miny,maxy]]
export(Array) var ElevationBoundaries = [0,0]  # [minElevation,maxElevation]

var TileSetsData:Dictionary = {} # {TSName:{tileName:tileID}}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### INIT ###
func initialize(TileMaps:Array) -> bool:
	# Create list of available tiles and tilesets
	TileSetsData = _init_available_TM_tiles(TileMaps)
	
	if not _check_ID_compatibility():
		push_error("Failed to initialize MapData!")
		return false
	
	return true


# Function takes a list of all existing tileMaps to prepare TileSetsData
# TileSetsData = { TSName:{tileName:tileID} }
func _init_available_TM_tiles(TileMaps:Array) -> Dictionary:
	var output:Dictionary = {}
	
	for tileMap in TileMaps:
		var TSName:String = tileMap.get_name()
		var tileSet:TileSet = tileMap.tile_set
		
		output[TSName] = {}
		
		var tileIDs:Array = tileSet.get_tiles_ids()
		var tileNames:Array = LibK.TS.get_tile_names(tileSet)
		
		for index in range(tileNames.size()):
			output[TSName][tileNames[index]] = tileIDs[index]
	
	return output


# Function is chcecking for inconsistency between TileSetsData and TDataLog
# If a tileName has different id in TDataLog change id to the TileSetsData one
# This functions prevent mixing tiles if tileset has changed (tile was removed and then added on different id ect..)
func _check_ID_compatibility() -> bool:
	# First check if all TileMaps exist
	for TSName in TData:
		if not TileSetsData.has(TSName):
			Logger.logErr(["TSName (existing in TData) doesnt exist in available TileSets: " + TSName], get_stack())
			return false
	
	# Check if saved tile IDs are the same as in TileMaps
	for TDLog in TDataLog:
		var tileName:String = TDLog[0]
		var TSName:String = TDLog[1]
		
		if not TileSetsData[TSName].has(tileName):
			Logger.logErr(["Tile called: " + tileName +", saved in TDataLog doesnt exist in TileSetsData: " + TSName], get_stack())
			return false
		
		var tileIDLog = TDataLog[TDLog]
		var tileIDTSD = TileSetsData[TSName][tileName]
		
		if tileIDTSD != tileIDLog:
			_update_all_tile_IDs(tileIDTSD,tileName,TSName)
	
	return true

# Update every single tile in the map
# Inefficient if the error occurs but at least the map is updated
func _update_all_tile_IDs(tileIDTS:int,tileName:String,TSName:String) -> void:
	Logger.logErr(["Tile called: " + tileName + ", has outdated ID: " + str(TDataLog[[tileName,TSName]])], get_stack())
	Logger.logMS(["Updating tile: " + str([tileName,TSName]) + ", to current global ID: ", tileIDTS])
	
	# Update TData IDs
	for packedPos in TData[TSName]:
		if TData[TSName][packedPos][TDV.keys()[TDV.tileName]] == tileName:
			TData[TSName][packedPos][TDV.keys()[TDV.tileID]] = tileIDTS
	
	# Update TDataLog
	TDataLog[[tileName,TSName]] = tileIDTS
	Logger.logMS(["Update succesful!\n"])


### TData ###
func set_TData_on(TSName:String,packedPos:Array,tileName:String) -> bool:
	if not TData.has(TSName): TData[TSName] = {}
	
	if not TileSetsData.has(TSName):
		Logger.logErr(["TSName doesnt exist in available TileSets: " + TSName], get_stack())
		return false
	
	if not TileSetsData[TSName].has(tileName):
		Logger.logErr(["TileName doesnt exist in available TileSets: " + tileName], get_stack())
		return false
	
	var data = _pack_data(TSName,tileName)
	
	_TDataLog_update(data,TSName)
	TData[TSName][packedPos] = data
	return true


func remove_TData_on(TSName:String,packedPos:Array) -> bool:
	if not TData.has(TSName):
		return false
	
	if not TData[TSName].has(packedPos):
		return false
	
	TData[TSName].erase(packedPos)
	
	return true


func get_TData_on(TSName:String,packedPos:Array) -> Dictionary:
	if not TileSetsData.has(TSName):
		Logger.logErr(["TSName doesnt exist in available TileSets: " + TSName], get_stack())
		return {}
	
	if not TData.has(TSName):
		return {}
	
	if not TData[TSName].has(packedPos):
		return {}
	
	return TData[TSName][packedPos]

# DATA PACKING #
# List of all must have keys in TData data
enum TDV {tileID,tileName} 

# Function that saves all existing tileNames and corresponding IDs
func _TDataLog_update(data:Dictionary,TSName:String) -> void:
	var tileName = data[ TDV.keys()[TDV.tileName] ]
	if [tileName,TSName] in TDataLog:
		return
	
	var tileID = data[ TDV.keys()[TDV.tileID] ]
	TDataLog[ [tileName,TSName] ] = tileID


# Universal packing of data (for TData)
func _pack_data(TSName:String,tileName:String) -> Dictionary:
	var data = {}
	for key in TDV:
		data[key] = null
	
	data[TDV.keys()[TDV.tileName]] = tileName
	data[TDV.keys()[TDV.tileID]] = TileSetsData[TSName][tileName]
	return data
