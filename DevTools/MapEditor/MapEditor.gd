### ----------------------------------------------------
### Map Editor main script
### For input details check MapEditorInput.gd
### ----------------------------------------------------

extends "res://DevTools/MapEditor/MapEditorInput.gd"

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _ready() -> void:
	VisualServer.set_default_clear_color(Color.darkslateblue)
	
	TileSelect.allTileMaps = $MapManager.get_tilemaps()
	_init_TM_selection()
	_init_tile_select()
	
	switch_TM_selection(0)

### ----------------------------------------------------
# Init
### ----------------------------------------------------
func _init_TM_selection():
	for tileMap in TileSelect.allTileMaps:
		var TMName:String = tileMap.get_name()
		UIElement.TMSelect.add_item (TMName)


func _init_tile_select():
	for tileMap in TileSelect.allTileMaps:
		TileSelect.tileData.append(LibK.TS.get_tile_names_and_IDs(tileMap.tile_set))
### ----------------------------------------------------


### ----------------------------------------------------
# Drawing
### ----------------------------------------------------
func _draw():
	var mousePos:Vector2 = get_global_mouse_position()
	_draw_selection_square(mousePos)
	_draw_selection_chunk(mousePos)
	_draw_loaded_chunks()


# Draws a square to indicate current cell pointed by mouse cursor
func _draw_selection_square(mousePos:Vector2):
	var size = Vector2(DATA.BASE_SCALE,DATA.BASE_SCALE)
	var cellPosV2:Vector2 = LibK.Vectors.scale_down_vec2(mousePos, DATA.BASE_SCALE)
	var posV2:Vector2 = cellPosV2 * DATA.BASE_SCALE
	
	var rect = Rect2(posV2,size)
	Info.CellLabel.text = "Cell: " + str(cellPosV2)
	
	draw_rect(rect,Color.crimson,false,1)


# Draws a square to indicate current chunk pointed by mouse cursor
func _draw_selection_chunk(mousePos:Vector2):
	var chunkScale:int = DATA.BASE_SCALE * DATA.CHUNK_SIZE
	var chunkV2:Vector2 = LibK.Vectors.scale_down_vec2(mousePos, DATA.CHUNK_SIZE*DATA.BASE_SCALE)
	var posV2:Vector2 = chunkV2 * chunkScale
	var rect = Rect2(posV2, Vector2(chunkScale, chunkScale))
	
	Info.ChunkLabel.text = "Chunk: " + str(chunkV2)
	draw_rect(rect, Color.black, false, 1)


func _draw_loaded_chunks():
	for posV3 in $MapManager.LoadedChunks:
		var chunkScale:int = DATA.BASE_SCALE * DATA.CHUNK_SIZE
		var posV2:Vector2 = LibK.Vectors.vec3_vec2(posV3) * chunkScale
		var rect = Rect2(posV2, Vector2(chunkScale, chunkScale))
		draw_rect(rect, Color.red, false, 1)
	
### ----------------------------------------------------
