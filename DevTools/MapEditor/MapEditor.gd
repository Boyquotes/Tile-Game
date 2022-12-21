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
	
	$MapManager.set_blank_save()

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


# Draws a square to indicate current cell pointed by mouse cursor
func _draw_selection_square(mousePos:Vector2):
	var size = Vector2(DATA.Map.BASE_SCALE,DATA.Map.BASE_SCALE)
	var cellPos:Vector2 = DATA.Map.GET_TILE_ON_POSITION(mousePos)
	var pos:Vector2 = cellPos * DATA.Map.BASE_SCALE
	
	var rect = Rect2(pos,size)
	Info.CellLabel.text = "Cell: " + str(cellPos)
	
	draw_rect(rect,Color.crimson,false,1)


# Draws a square to indicate current chunk pointed by mouse cursor
func _draw_selection_chunk(mousePos:Vector2):
	var chunkScale:int = DATA.Map.BASE_SCALE * DATA.Map.CHUNK_SIZE
	var chunkPos:Vector2 = DATA.Map.GET_CHUNK_ON_POSITION(mousePos, false)
	var pos:Vector2 = chunkPos * chunkScale
	var rect = Rect2(pos, Vector2(chunkScale, chunkScale))
	
	Info.ChunkLabel.text = "Chunk: " + str(chunkPos)
	draw_rect(rect, Color.black, false, 1)
### ----------------------------------------------------
