### ----------------------------------------------------
### Map Editor
### ----------------------------------------------------
extends "res://DevTools/MapEditor/MapEditorInput.gd"

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# INIT #
func _ready() -> void:
	VisualServer.set_default_clear_color(Color.darkslateblue)
	AllTileMaps = $MapManager.get_tilemaps()
	
	switch_TM_selection(0)
	switch_TL_selection(0)
	
	$MapManager.set_blank_save()


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
	CellLabel.text = "Cell: " + str(cellPos)
	
	draw_rect(rect,Color.crimson,false,1)


# Draws a square to indicate current chunk pointed by mouse cursor
func _draw_selection_chunk(mousePos:Vector2):
	var chunkScale:int = DATA.Map.BASE_SCALE * DATA.Map.CHUNK_SIZE
	var size:Vector2 = Vector2(chunkScale, chunkScale)
	var chunkPos:Vector2 = DATA.Map.GET_CHUNK_ON_POSITION(mousePos, false)
	
	var pos:Vector2 = chunkPos * chunkScale
	
	var rect = Rect2(pos,size)
	ChunkLabel.text = "Chunk: " + str(chunkPos)
	
	draw_rect(rect, Color.black, false, 1)
### ----------------------------------------------------
