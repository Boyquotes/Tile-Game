### ----------------------------------------------------
### Is a container for all TileMaps
### Takes care of showing the map to the player
### ----------------------------------------------------
extends SaveManager

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var isReady:bool = false # Optimization of getting TileMaps
var TileMaps:Array = []  # Reference to all tilemaps

var LoadedChunks:Array = [] # List of chunk loaded to tilemap
# LoadedChunks = [[chunkPos,elevationLevel],...]

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### RENDERING ###
func update_visable_map(GFObjectChunks:Array,GFObjectElevation:int):
	GFObjectChunks = _initialize(GFObjectChunks,GFObjectElevation)
	
	# Loading chunks that are not yet rendered
	for packedChunk in GFObjectChunks:
		# Check if chunk is already loaded
		if LoadedChunks.has(packedChunk):
			continue
		
		# Load chunk
		_load_chunk_to_tilemap(packedChunk)
		LoadedChunks.append(packedChunk)
	
	# Unloading chunks that are not in focus object range
	var chunksToUnload = [] # Not doing that messes up for loop when eraseing
	for packedChunk in LoadedChunks:
		# Check if chunk to load is already loaded
		if GFObjectChunks.has(packedChunk):
			continue
		chunksToUnload.append(packedChunk)
	
	for packedChunk in chunksToUnload:
		# Unload chunks that are not meant to be loaded
		_unload_chunk_from_tilemap(packedChunk)
		LoadedChunks.erase(packedChunk)
	
	# Update bitmask regions
	for tileMap in TileMaps:
		tileMap.update_bitmask_region()


# Used to get chunks only on a given elevation
# Render only current elevation chunks
func _initialize(PackedArray:Array,elevation:int) -> Array:
	var result = []
	for packedChunk in PackedArray:
		if packedChunk[1] != elevation:
			continue
		result.append(packedChunk)
	
	if isReady:
		return result
	isReady = true
	
	# Saves reference to all TileMaps in an array
	TileMaps = get_tilemaps()
	return result

# LOADING CHUNKS #
# Loads all tiles in a chunk
func _load_chunk_to_tilemap(packedChunk:Array):
	var chunkPos = packedChunk[0]
	var elevationLevel = packedChunk[1]
	
	# Get positions inside the chunk
	var chunkTilePos = DATA.Map.GET_CHUNK_TILE_POSITIONS(chunkPos)
	
	# For every tile in chunk
	for tilePos in chunkTilePos:
		var packedPos = [tilePos,elevationLevel]
		_load_tiles_on_position(packedPos)


# Loads tiles from every TileMap on position
func _load_tiles_on_position(packedPos:Array):
	# Loop to check for every TileMap position
	for tileMap in TileMaps:
		var TMName = tileMap.get_name()
		var data:Dictionary = SaveData.MapData.get_TData_on(TMName,packedPos)
		
		# Check if there is any saved data on this position
		if data.size() == 0:
			tileMap.set_cellv(packedPos[0],-1)
			continue
		
		# Set tile on tilemap
		var tileID = data[ SaveData.MapData.TDV.keys()[SaveData.MapData.TDV.tileID] ]
		tileMap.set_cellv(packedPos[0],tileID)


# UNLOADING CHUNKS #
# Unloads all tiles in a chunk
func _unload_chunk_from_tilemap(packedChunk:Array):
	var chunkPos = packedChunk[0]
	
	# Get positions inside the chunk
	var chunkTilePos = DATA.Map.GET_CHUNK_TILE_POSITIONS(chunkPos)
	
	# For every tile in chunk
	for tilePos in chunkTilePos:
		# Loop for every TileMap
		for tileMap in TileMaps:
			tileMap.set_cellv(tilePos,-1)


# UPDATING CHUNKS #
# Reloads all tiles on given position
func refresh_tile(packedPos:Array):
	var tileChunk:Array = [DATA.Map.GET_CHUNK_ON_POSITION(packedPos[0]),packedPos[1]]
	if not tileChunk in LoadedChunks:
		Logger.logMS(["Tried to refresh unloaded chunk tile."], true)
		return
	
	_load_tiles_on_position(packedPos)


# Reloads all chunks
func refresh_all_chunks():
	for packedChunk in LoadedChunks:
		_load_chunk_to_tilemap(packedChunk)
