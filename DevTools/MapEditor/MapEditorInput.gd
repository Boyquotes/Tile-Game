### ----------------------------------------------------
### Input management for MapEditor
### ----------------------------------------------------
extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

onready var PosInfo = {
	ChunkLabel = $UIElements/MC/GC/PosInfo/Chunk,
	ElevationLabel = $UIElements/MC/GC/PosInfo/Elevation,
	CellLabel = $UIElements/MC/GC/PosInfo/Cell,
}

onready var TileSelect = {
	filter = "",		# Item filter keyword
	allTileMaps = [],	# List of all tilemaps
	tileData = [],		# Data regarding tiles (same order as all tilemaps)
	shownTiles = [],	# List of all show tiles (in TileList)
	TMIndex = 0,		# TileMap index (allTileMaps)
	listIndex = 0,		# Index of selected item
}

onready var UIElement = {
	Parent = $UIElements/MC,
	TileScroll = $UIElements/MC/GC/TileScroll,
	TMSelect = $UIElements/MC/GC/TileScroll/TMSelect,
	TileList = $UIElements/MC/GC/TileScroll/ItemList,
	SaveEdit = $UIElements/MC/GC/PosInfo/SaveEdit,
	LoadEdit = $UIElements/MC/GC/PosInfo/LoadEdit,
}

onready var SaveLoad = {
	isSaving = false,
	isLoading = false,
}

var inputActive:bool = true
var UIZone: bool = false

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _input(event: InputEvent) -> void:
	if not inputActive: return
	
	saveInput(event)
	loadInput(event)
	if SaveLoad.isSaving or SaveLoad.isLoading: return
	
	TM_selection_input(event)
	tile_selection_input(event)
	if UIZone: return
	
	update()
	update_MapManager_chunks()
	
	set_tile_input(event)

### ----------------------------------------------------
# Selecting TileMap
### ----------------------------------------------------
func TM_selection_input(event: InputEvent):
	if   event.is_action_pressed(INPUT.TR["E"]): 
		switch_TM_selection(TileSelect.TMIndex + 1)
	elif event.is_action_pressed(INPUT.TR["Q"]): 
		switch_TM_selection(TileSelect.TMIndex - 1)


func switch_TM_selection(value:int):
	TileSelect.TMIndex = value
	if TileSelect.TMIndex > (TileSelect.allTileMaps.size() - 1): TileSelect.TMIndex = 0
	if TileSelect.TMIndex < 0: TileSelect.TMIndex = (TileSelect.allTileMaps.size() - 1)
	
	TileSelect.listIndex = 0
	fill_item_list()
	
	UIElement.TMSelect.select(TileSelect.TMIndex)
	switch_tile_selection(TileSelect.listIndex)


func _on_TMSelect_item_selected(index:int) -> void:
	switch_TM_selection(index)


# Fills item list with TileMap tiles
func fill_item_list():
	UIElement.TileList.clear()
	TileSelect.shownTiles.clear()
	
	var tileMap:TileMap = TileSelect.allTileMaps[TileSelect.TMIndex]
	for packed in TileSelect.tileData[TileSelect.TMIndex]:
		var tileName:String = packed[0]
		var tileID:int = packed[1]
		var tileTexture:Texture = LibK.TS.get_tile_texture(tileID, tileMap.tile_set)
		
		UIElement.TileList.add_item(tileName,tileTexture,true)
		TileSelect.shownTiles.append([tileName,tileID])
### ----------------------------------------------------

### ----------------------------------------------------
# Selecting Tile
### ----------------------------------------------------
func tile_selection_input(event: InputEvent):
	if   event.is_action_pressed(INPUT.TR["X"]): 
		switch_tile_selection(TileSelect.listIndex + 1)
	elif event.is_action_pressed(INPUT.TR["Z"]): 
		switch_tile_selection(TileSelect.listIndex - 1)


func switch_tile_selection(value:int):
	TileSelect.listIndex = value
	if TileSelect.listIndex > (UIElement.TileList.get_item_count() - 1): 
		TileSelect.listIndex = 0
	if TileSelect.listIndex < 0: 
		TileSelect.listIndex = (UIElement.TileList.get_item_count() - 1)
	
	UIElement.TileList.select(TileSelect.listIndex)


func _on_ItemList_item_selected(index:int) -> void:
	switch_tile_selection(index)
### ----------------------------------------------------


### ----------------------------------------------------
# Placing Tile
### ----------------------------------------------------
func set_tile_input(event:InputEvent):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if event.button_mask == BUTTON_MASK_LEFT:  
			var tileID:int = TileSelect.shownTiles[TileSelect.listIndex][1]
			set_selected_tile(tileID)
		if event.button_mask == BUTTON_MASK_RIGHT: 
			set_selected_tile(-1)


func set_selected_tile(tileID:int):
	var tileMap:TileMap = TileSelect.allTileMaps[TileSelect.TMIndex]
	var mousePos:Vector2 = tileMap.world_to_map(get_global_mouse_position())
	var packedPos:Array = [mousePos, $Cam.currentElevation]
	var chunkPos:Array = [DATA.Map.GET_CHUNK_ON_POSITION(mousePos), $Cam.currentElevation]
	
	if not chunkPos in $MapManager.LoadedChunks: return
	
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
		SaveLoad.SaveEdit.show()
		SaveLoad.SaveEdit.grab_focus()
	
	if event.is_action_pressed(INPUT.TR["ESC"]) and SaveLoad.isSaving:
		$Cam.inputActive = true
		SaveLoad.isSaving = false
		SaveLoad.SaveEdit.hide()


func loadInput(event:InputEvent) -> void:
	if SaveLoad.isSaving: return
	
	if event.is_action_pressed(INPUT.TR["LAlt"]) and not SaveLoad.isLoading:
		$Cam.inputActive = false
		SaveLoad.isLoading = true
		SaveLoad.LoadEdit.show()
		SaveLoad.LoadEdit.grab_focus()
	
	if event.is_action_pressed(INPUT.TR["ESC"]) and SaveLoad.isLoading:
		$Cam.inputActive = true
		SaveLoad.isLoading = false
		SaveLoad.LoadEdit.hide()


func _on_SaveEdit_text_entered(SaveName: String) -> void:
	$MapManager.SaveData.SaveName = SaveName
	$MapManager.save_current_SaveData()


func _on_LoadEdit_text_entered(SaveName: String) -> void:
	if not LibK.Files.file_exist(DATA.SAVE_FLODER_PATH + SaveName + ".res"):
		Logger.logErr(["Save called: ", SaveName, " doesn't exist!"], get_stack())
		return
	
	$MapManager.load_SaveData(SaveName)
	update_MapManager_chunks()
	$MapManager.refresh_all_chunks()
### ----------------------------------------------------


### ----------------------------------------------------
# UI Control
### ----------------------------------------------------
func _physics_process(_delta: float) -> void:
	if LibK.UI.is_mouse_on_ui(UIElement.TileScroll, UIElement.Parent):
		UIZone = true
		$Cam.inputActive = false
	else:	
		UIZone = false
		$Cam.inputActive = true
### ----------------------------------------------------
