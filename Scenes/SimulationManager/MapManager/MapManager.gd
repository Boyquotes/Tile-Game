### ----------------------------------------------------
### Container for all TileMaps
### Takes care of showing the map to the player
### ----------------------------------------------------

extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# Reference to all tilemaps
var TileMaps:Array = [] 

# List of chunks loaded to tilemap (format array for comparing)
var LoadedChunks:Array = [] # [ Vector3, ... ]

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _enter_tree() -> void:
	for packed in LibK.Files.get_file_list_at_dir(DATA.MAP.TILEMAPS_DIR):
		var filePath:String = packed[0]
		var fileName:String = packed[1]
		var TMScene:PackedScene = load(filePath + "/" + fileName + ".tscn")
		var TMInstance = TMScene.instance()
		add_child(TMInstance)
	TileMaps = get_tilemaps()

### ----------------------------------------------------
# Getting chunks to load / unload
### ----------------------------------------------------
func update_visable_map(ChunksToLoad:Array) -> void:
	# Loading chunks that are not yet rendered
	for chunkV3 in ChunksToLoad:
		if LoadedChunks.has(chunkV3): continue
		_load_chunk_to_tilemap(chunkV3)
	
	# Unload old chunks that are not in range (iterate backwards)
	for i in range(LoadedChunks.size() - 1, -1, -1):
		var chunkV3:Vector3 = LoadedChunks[i]
		if ChunksToLoad.has(chunkV3): continue
		LoadedChunks.remove(i)
		_unload_chunk_from_tilemap(chunkV3)
	
	for tileMap in TileMaps: tileMap.update_bitmask_region()
### ----------------------------------------------------


### ----------------------------------------------------
# Loading chunks
### ----------------------------------------------------
func _load_chunk_to_tilemap(chunkV3:Vector3):
	for posV3 in LibK.Vectors.vec3_get_pos_in_chunk(chunkV3, DATA.MAP.CHUNK_SIZE):
		_load_tiles_on_position(posV3)
	LoadedChunks.append(chunkV3)


# Loads tiles from every TileMap on position
func _load_tiles_on_position(posV3:Vector3):
	for tileMap in TileMaps:
		var TMName = tileMap.get_name()
		var tileData:TileData = SAVE.CurrentMap.get_tile_on(TMName, posV3)
		tileMap.set_cellv(LibK.Vectors.vec3_vec2(posV3), tileData.tileID)
### ----------------------------------------------------


### ----------------------------------------------------
# Unloading chunks
### ----------------------------------------------------
func _unload_chunk_from_tilemap(chunkV3:Vector3):
	for posV3 in LibK.Vectors.vec3_get_pos_in_chunk(chunkV3, DATA.MAP.CHUNK_SIZE):
		for tileMap in TileMaps:
			tileMap.set_cellv(LibK.Vectors.vec3_vec2(posV3), -1)
### ----------------------------------------------------


### ----------------------------------------------------
# Update map
### ----------------------------------------------------
func refresh_tile(posV3:Vector3):
	var chunkV3:Vector3 = LibK.Vectors.scale_down_vec3(posV3, DATA.MAP.CHUNK_SIZE)
	if not chunkV3 in LoadedChunks:
		Logger.logErr(["Tried to refresh unloaded tile: ", posV3],get_stack())
		return
	_load_tiles_on_position(posV3)


func refresh_chunk(chunkV3:Vector3):
	if not chunkV3 in LoadedChunks:
		Logger.logErr(["Tried to refresh unloaded chunk: ", chunkV3],get_stack())
		return
	for posV3 in LibK.Vectors.vec3_get_pos_in_chunk(chunkV3, DATA.MAP.CHUNK_SIZE):
		_load_tiles_on_position(posV3)


func refresh_all_chunks():
	for chunkV3 in LoadedChunks: refresh_chunk(chunkV3)


func unload_all_chunks():
	LoadedChunks.clear()
### ----------------------------------------------------


### ----------------------------------------------------
# Utility
### ----------------------------------------------------
func get_tilemaps() -> Array:
	var TM:Array = []
	for node in get_children(): if node is TileMap: TM.append(node)
	return TM
### ----------------------------------------------------
