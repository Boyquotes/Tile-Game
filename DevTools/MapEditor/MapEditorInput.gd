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
	filter = "",
	AllTileMaps = [],
	TileData = [],
	ShownTiles = [],
	TMIndex = 0,
	ListIndex = 0,
	TMNameLabel = $UIElements/MC/GC/TileScroll/TMName,
	TileList = $UIElements/MC/GC/TileScroll/ItemList,
}

onready var SaveLoad = {
	SaveEdit = $UIElements/MC/GC/PosInfo/SaveEdit,
	LoadEdit = $UIElements/MC/GC/PosInfo/LoadEdit,
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
	TD_selection_input(event)
	if UIZone: return
	
	update()
	update_MapManager_chunks()
	
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
	TileSelect.ListIndex = 0
	switch_list_selection(TileSelect.ListIndex)


# Fills item list with TileMap tiles
func fill_item_list():
	TileSelect.TileList.clear()
	TileSelect.ShownTiles.clear()
	
	var tileMap:TileMap = TileSelect.AllTileMaps[TileSelect.TMIndex]
	for packed in TileSelect.TileData[TileSelect.TMIndex]:
		var tileName:String = packed[0]
		var tileID:int = packed[1]
		var tileTexture:Texture = LibK.TS.get_tile_texture(tileID, tileMap.tile_set)
		
		TileSelect.TileList.add_item(tileName,tileTexture,true)
		TileSelect.ShownTiles.append([tileName,tileID])
### ----------------------------------------------------

### ----------------------------------------------------
# Selecting Tile
### ----------------------------------------------------
func TD_selection_input(event: InputEvent):
	if   event.is_action_pressed(INPUT.TR["X"]): switch_list_selection(1)
	elif event.is_action_pressed(INPUT.TR["Z"]): switch_list_selection(-1)


func switch_list_selection(value:int):
	TileSelect.ListIndex += value
	
	if TileSelect.ListIndex > (TileSelect.TileList.get_item_count() - 1): TileSelect.ListIndex = 0
	if TileSelect.ListIndex < 0: TileSelect.ListIndex = (TileSelect.TileList.get_item_count() - 1)
	
	TileSelect.TileList.select(TileSelect.ListIndex)
### ----------------------------------------------------


### ----------------------------------------------------
# Placing Tile
### ----------------------------------------------------
func set_tile_input(event:InputEvent):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if event.button_mask == BUTTON_MASK_LEFT:  
			var tileID:int = TileSelect.ShownTiles[TileSelect.ListIndex][1]
			set_selected_tile(tileID)
		if event.button_mask == BUTTON_MASK_RIGHT: 
			set_selected_tile(-1)


func set_selected_tile(tileID:int):
	var tileMap:TileMap = TileSelect.AllTileMaps[TileSelect.TMIndex]
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
		Logger.logMS(["Save called: ", SaveName, " doesn't exist!"], true)
		return
	
	$MapManager.load_SaveData(SaveName)
	update_MapManager_chunks()
	$MapManager.refresh_all_chunks()
### ----------------------------------------------------


### ----------------------------------------------------
# UI Control
### ----------------------------------------------------
func _on_TileScroll_mouse_entered() -> void:
	UIZone = true
	$Cam.inputActive = false


func _on_TileScroll_mouse_exited() -> void:
	UIZone = false
	$Cam.inputActive = true
### ----------------------------------------------------
