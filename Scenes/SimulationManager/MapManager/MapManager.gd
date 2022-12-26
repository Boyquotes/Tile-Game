### ----------------------------------------------------
### Is a container for all TileMaps
### Takes care of showing the map to the player
### ----------------------------------------------------
extends SaveManager

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var LoadedChunks:Array = [] # List of chunk loaded to tilemap
# LoadedChunks = [[chunkPos,elevationLevel],...]

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### ----------------------------------------------------
# Getting chunks to load / unload
### ----------------------------------------------------
func update_visable_map(ChunksToLoad:Array,GFObjectElevation:int):
	ChunksToLoad = _get_chunks_on_elevation(ChunksToLoad,GFObjectElevation)
	
	# Loading chunks that are not yet rendered
	for packedChunk in ChunksToLoad:
		if LoadedChunks.has(packedChunk): continue
		_load_chunk_to_tilemap(packedChunk)
	
	# Unload old chunks that are not in range (iterate backwards)
	for i in range(LoadedChunks.size() - 1, -1, -1):
		var packedChunk = LoadedChunks[i]
		if ChunksToLoad.has(packedChunk): continue
		LoadedChunks.remove(i)
		_unload_chunk_from_tilemap(packedChunk)
	
	for tileMap in TileMaps: tileMap.update_bitmask_region()


# Used to get chunks only on a given elevation
# Render only current elevation chunks
func _get_chunks_on_elevation(PackedArray:Array,elevation:int) -> Array:
	var result = []
	for packedChunk in PackedArray:
		if packedChunk[1] != elevation: continue
		result.append(packedChunk)
	
	return result
### ----------------------------------------------------

### ----------------------------------------------------
# Loading chunks
### ----------------------------------------------------
func _load_chunk_to_tilemap(packedChunk:Array):
	var chunkPos = packedChunk[0]
	var elevationLevel = packedChunk[1]
	
	# For every tile in chunk
	for tilePos in DATA.Map.GET_CHUNK_TILE_POSITIONS(chunkPos):
		_load_tiles_on_position([tilePos,elevationLevel])
	LoadedChunks.append(packedChunk)


# Loads tiles from every TileMap on position
func _load_tiles_on_position(packedPos:Array):
	# Loop to check for every TileMap position
	for tileMap in TileMaps:
		var TMName = tileMap.get_name()
		var data:Dictionary = SaveData.MapData.get_TData_on(TMName,packedPos)
		
		# If no data on this position put blank
		if data.size() == 0:
			tileMap.set_cellv(packedPos[0],-1)
			continue
		
		# Set tile on tilemap
		var tileID = data[ SaveData.MapData.TDV.keys()[SaveData.MapData.TDV.tileID] ]
		tileMap.set_cellv(packedPos[0],tileID)
### ----------------------------------------------------


### ----------------------------------------------------
# Unloading chunks
### ----------------------------------------------------
func _unload_chunk_from_tilemap(packedChunk:Array):
	var chunkPos = packedChunk[0]
	
	# For every tile in chunk
	for tilePos in DATA.Map.GET_CHUNK_TILE_POSITIONS(chunkPos):
		for tileMap in TileMaps: tileMap.set_cellv(tilePos,-1)
### ----------------------------------------------------


### ----------------------------------------------------
# Update map
### ----------------------------------------------------
func refresh_tile(packedPos:Array):
	var tileChunk:Array = [DATA.Map.GET_CHUNK_ON_POSITION(packedPos[0]),packedPos[1]]
	if not tileChunk in LoadedChunks:
		Logger.logErr(["Tried to refresh unloaded chunk tile."], get_stack())
		return
	_load_tiles_on_position(packedPos)


func refresh_all_chunks():
	for packedChunk in LoadedChunks:
		_load_chunk_to_tilemap(packedChunk)


func unload_all_chunks():
	LoadedChunks.clear()
### ----------------------------------------------------
