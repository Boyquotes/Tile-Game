### ----------------------------------------------------
### Input management for MapEditor
### ----------------------------------------------------
extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# PosInfo
onready var ChunkLabel = $UICanvas/Control/GridContainer/PosInfo/Chunk
onready var ElevationLabel = $UICanvas/Control/GridContainer/PosInfo/Elevation
onready var CellLabel = $UICanvas/Control/GridContainer/PosInfo/Cell

# TileScroll
onready var TMNameLabel = $UICanvas/Control/GridContainer/TileScroll/TMName
onready var TileList = $UICanvas/Control/GridContainer/TileScroll/ItemList

var inputActive:bool = true

var AllTileMaps:Array = []
var TMIndex:int = 0

var TLIndex:int = 0

# Save/Load
var isSaving:bool = false
var isLoading:bool = false

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# INPUT #
func _input(event: InputEvent) -> void:
	if not inputActive:
		return
	
	update()
	update_MapManager_chunks()
	
	# Save/Load
	saveInput(event)
	loadInput(event)
	
	if isSaving or isLoading:
		return
	
	# TileMap switching
	if event.is_action_pressed("E"):
		switch_TM_selection(1)
	elif event.is_action_pressed("Q"):
		switch_TM_selection(-1)
	
	# Tile switching
	if event.is_action_pressed("X"):
		switch_TL_selection(1)
	elif event.is_action_pressed("Z"):
		switch_TL_selection(-1)
	
	# Placing tile
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if event.button_mask == BUTTON_MASK_LEFT:
			set_selected_tile(TLIndex)
		if event.button_mask == BUTTON_MASK_RIGHT:
			set_selected_tile(-1)


# Changes selected TileMap
func switch_TM_selection(value:int):
	TMIndex += value
	
	if TMIndex > (AllTileMaps.size() - 1): TMIndex = 0
	if TMIndex < 0: TMIndex = (AllTileMaps.size() - 1)
	
	TMNameLabel.text = AllTileMaps[TMIndex].get_name()
	
	fill_item_list()
	TLIndex = 0
	switch_TL_selection(0)


# Changes selected item (tile) in TileList
func switch_TL_selection(value:int):
	TLIndex += value
	
	if TLIndex > (TileList.get_item_count() - 1): TLIndex = 0
	if TLIndex < 0: TLIndex = (TileList.get_item_count() - 1)
	
	for ID in range(TileList.get_item_count()):
		TileList.set_item_disabled(ID,true)
	
	TileList.set_item_disabled(TLIndex,false)
	TileList.select(TLIndex)


# TILE LIST #
# Fills item list with TileMap tiles
func fill_item_list():
	TileList.clear()
	
	var tileSet:TileSet = AllTileMaps[TMIndex].tile_set
	for tileID in tileSet.get_tiles_ids():
		var tileName:String = tileSet.tile_get_name(tileID)
		var tileTexture:Texture = _get_tile_texture(tileID,tileSet)
		TileList.add_item(tileName,tileTexture,true)


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


# MAP MANAGER #
# Renders chunks as in normal game based on camera position (as simulated entity)
func update_MapManager_chunks():
	var camChunk:Vector2 = DATA.Map.GET_CHUNK_ON_POSITION($Cam.global_position, false)
	var chunksToRender:Array = []
	var posToRender:Array = LibK.Vectors.GET_POS_RANGE_V2(1,camChunk,false)
	
	for pos in posToRender:
		chunksToRender.append([pos,$Cam.currentElevation])
	
	$MapManager.update_visable_map(chunksToRender,$Cam.currentElevation)


func set_selected_tile(tileID:int):
	var tileMap:TileMap = AllTileMaps[TMIndex]
	
	var packedPos:Array = [tileMap.world_to_map(get_global_mouse_position()),$Cam.currentElevation]
	var TMName = tileMap.get_name()
	
	if tileID == -1:
		$MapManager.SaveData.MapData.remove_TData_on(TMName,packedPos)
		$MapManager.refresh_tile(packedPos)
		return
	
	var tileName = tileMap.tile_set.tile_get_name(tileID)
	$MapManager.SaveData.MapData.set_TData_on(TMName,packedPos,tileName)
	$MapManager.refresh_tile(packedPos)


# SAVE/LOAD #
func saveInput(event:InputEvent) -> void:
	if isLoading:
		return
	
	if not isSaving:
		if event.is_action_pressed("LCtrl"):
			$Cam.inputActive = false
			isSaving = true
			$UICanvas/Control/SaveEdit.show()
			$UICanvas/Control/SaveEdit.grab_focus()
	
	if isSaving:
		if event.is_action_pressed("ESC"):
			$Cam.inputActive = true
			isSaving = false
			$UICanvas/Control/SaveEdit.hide()


func loadInput(event:InputEvent) -> void:
	if isSaving:
		return
	
	if not isLoading:
		if event.is_action_pressed("LAlt"):
			$Cam.inputActive = false
			isLoading = true
			$UICanvas/Control/LoadEdit.show()
			$UICanvas/Control/LoadEdit.grab_focus()
	
	if isLoading:
		if event.is_action_pressed("ESC"):
			$Cam.inputActive = true
			isLoading = false
			$UICanvas/Control/LoadEdit.hide()

func _on_SaveEdit_text_entered(SaveName: String) -> void:
	$MapManager.SaveData.SaveName = SaveName
	$MapManager.save_current_SaveData()


func _on_LoadEdit_text_entered(SaveName: String) -> void:
	if not LibK.Files.file_exist($MapManager.SaveFolderPath+SaveName+".res"):
		Logger.logMS(["Save called: ", SaveName, " doesn't exist!"], true)
		return
	
	$MapManager.load_SaveData(SaveName)
	update_MapManager_chunks()
	$MapManager.refresh_all_chunks()
