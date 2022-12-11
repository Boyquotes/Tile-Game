### ----------------------------------------------------
### Input management for MapEditor
### ----------------------------------------------------
extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

onready var PosInfo = {
	ChunkLabel = $UICanvas/Control/GridContainer/PosInfo/Chunk,
	ElevationLabel = $UICanvas/Control/GridContainer/PosInfo/Elevation,
	CellLabel = $UICanvas/Control/GridContainer/PosInfo/Cell,
}

onready var TileSelect = {
	AllTileMaps = [],
	TMIndex = 0,
	TLIndex = 0,
	TMNameLabel = $UICanvas/Control/GridContainer/TileScroll/TMName,
	TileList = $UICanvas/Control/GridContainer/TileScroll/ItemList,
}

onready var SaveLoad = {
	isSaving = false,
	isLoading = false,
}

var inputActive:bool = true

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _input(event: InputEvent) -> void:
	if not inputActive: return
	
	update()
	update_MapManager_chunks()
	
	saveInput(event)
	loadInput(event)
	
	if SaveLoad.isSaving or SaveLoad.isLoading: return
	
	TM_selection_input(event)
	TL_selection_input(event)
	
	set_tile_input(event)

### ----------------------------------------------------
# Selecting TileMap
### ----------------------------------------------------
func TM_selection_input(event: InputEvent):
	if   event.is_action_pressed(INPUT.TR["E"]): switch_TM_selection(1)
	elif event.is_action_pressed(INPUT.TR["Q"]): switch_TM_selection(-1)


func switch_TM_selection(value:int):
	TileSelect.TMIndex += value
	
	if TileSelect.TMIndex > (TileSelect.AllTileMaps.size() - 1): TileSelect.TMIndex = 0
	if TileSelect.TMIndex < 0: TileSelect.TMIndex = (TileSelect.AllTileMaps.size() - 1)
	
	TileSelect.TMNameLabel.text = TileSelect.AllTileMaps[TileSelect.TMIndex].get_name()
	
	fill_item_list()
	TileSelect.TLIndex = 0
	switch_TL_selection(0)


# Fills item list with TileMap tiles
func fill_item_list():
	TileSelect.TileList.clear()
	
	var tileSet:TileSet = TileSelect.AllTileMaps[TileSelect.TMIndex].tile_set
	for tileID in tileSet.get_tiles_ids():
		var tileName:String = tileSet.tile_get_name(tileID)
		var tileTexture:Texture = _get_tile_texture(tileID,tileSet)
		TileSelect.TileList.add_item(tileName,tileTexture,true)


# Gets tile texture from TileSet
func _get_tile_texture(tileID:int,tileSet:TileSet) -> Texture:
	var fullTexture:Texture = tileSet.tile_get_texture(tileID)
	var textureRect:Rect2 = tileSet.tile_get_region(tileID)
	
	# Crop tileset texture
	var atlas_texture:AtlasTexture = AtlasTexture.new()
	atlas_texture.set_atlas(fullTexture)
	atlas_texture.set_region(textureRect)
	
	# Cast texture
	var tileTexture:Texture = atlas_texture
	
	# Crop tile texture
	var tileMode = tileSet.tile_get_tile_mode(tileID)
	if tileMode != TileSet.SINGLE_TILE:
		atlas_texture = AtlasTexture.new()
		atlas_texture.set_atlas(tileTexture)
		atlas_texture.set_region( Rect2(Vector2(0,0),tileSet.autotile_get_size(tileID)) )
	
	return atlas_texture
### ----------------------------------------------------

### ----------------------------------------------------
# Selecting Tile
### ----------------------------------------------------
func TL_selection_input(event: InputEvent):
	if   event.is_action_pressed(INPUT.TR["X"]): switch_TL_selection(1)
	elif event.is_action_pressed(INPUT.TR["Z"]): switch_TL_selection(-1)


func switch_TL_selection(value:int):
	TileSelect.TLIndex += value
	
	if TileSelect.TLIndex > (TileSelect.TileList.get_item_count() - 1): TileSelect.TLIndex = 0
	if TileSelect.TLIndex < 0: TileSelect.TLIndex = (TileSelect.TileList.get_item_count() - 1)
	
	for ID in range(TileSelect.TileList.get_item_count()):
		TileSelect.TileList.set_item_disabled(ID,true)
	
	TileSelect.TileList.set_item_disabled(TileSelect.TLIndex,false)
	TileSelect.TileList.select(TileSelect.TLIndex)
### ----------------------------------------------------


### ----------------------------------------------------
# Placing Tile
### ----------------------------------------------------
func set_tile_input(event:InputEvent):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if event.button_mask == BUTTON_MASK_LEFT:  set_selected_tile(TileSelect.TLIndex)
		if event.button_mask == BUTTON_MASK_RIGHT: set_selected_tile(-1)


func set_selected_tile(tileID:int):
	var tileMap:TileMap = TileSelect.AllTileMaps[TileSelect.TMIndex]
	var packedPos:Array = [tileMap.world_to_map(get_global_mouse_position()), $Cam.currentElevation]
	var TMName = tileMap.get_name()
	
	if tileID == -1:
		$MapManager.SaveData.MapData.remove_TData_on(TMName,packedPos)
		$MapManager.refresh_tile(packedPos)
		return
	
	var tileName = tileMap.tile_set.tile_get_name(tileID)
	$MapManager.SaveData.MapData.set_TData_on(TMName,packedPos,tileName)
	$MapManager.refresh_tile(packedPos)
### ----------------------------------------------------


### ----------------------------------------------------
# Filter Items
### ----------------------------------------------------

### ----------------------------------------------------


### ----------------------------------------------------
# Update chunks
### ----------------------------------------------------

# Renders chunks as in normal game based on camera position (as simulated entity)
func update_MapManager_chunks():
	var camChunk:Vector2 = DATA.Map.GET_CHUNK_ON_POSITION($Cam.global_position, false)
	var chunksToRender:Array = []
	var posToRender:Array = LibK.Vectors.GET_POS_RANGE_V2(1,camChunk,false)
	
	for pos in posToRender:
		chunksToRender.append([pos,$Cam.currentElevation])
	
	$MapManager.update_visable_map(chunksToRender,$Cam.currentElevation)
### ----------------------------------------------------


### ----------------------------------------------------
# Save / Load
### ----------------------------------------------------
func saveInput(event:InputEvent) -> void:
	if SaveLoad.isLoading: return
	
	if event.is_action_pressed(INPUT.TR["LCtrl"]) and not SaveLoad.isSaving:
		$Cam.inputActive = false
		SaveLoad.isSaving = true
		$UICanvas/Control/SaveEdit.show()
		$UICanvas/Control/SaveEdit.grab_focus()
	
	if event.is_action_pressed(INPUT.TR["ESC"]) and SaveLoad.isSaving:
		$Cam.inputActive = true
		SaveLoad.isSaving = false
		$UICanvas/Control/SaveEdit.hide()


func loadInput(event:InputEvent) -> void:
	if SaveLoad.isSaving: return
	
	if event.is_action_pressed(INPUT.TR["LAlt"]) and not SaveLoad.isLoading:
		$Cam.inputActive = false
		SaveLoad.isLoading = true
		$UICanvas/Control/LoadEdit.show()
		$UICanvas/Control/LoadEdit.grab_focus()
	
	if event.is_action_pressed(INPUT.TR["ESC"]) and SaveLoad.isLoading:
		$Cam.inputActive = true
		SaveLoad.isLoading = false
		$UICanvas/Control/LoadEdit.hide()


func _on_SaveEdit_text_entered(SaveName: String) -> void:
	$MapManager.SaveData.SaveName = SaveName
	$MapManager.save_current_SaveData()


func _on_LoadEdit_text_entered(SaveName: String) -> void:
	if not LibK.Files.file_exist(DATA.SAVE_FLODER_PATH + SaveName + ".res"):
		Logger.logMS(["Save called: ", SaveName, " doesn't exist!"], true)
		return
	
	$MapManager.load_SaveData(SaveName)
	update_MapManager_chunks()
	$MapManager.refresh_all_chunks()
### ----------------------------------------------------
