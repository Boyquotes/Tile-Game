### ----------------------------------------------------
### Input management for MapEditor
### Key inputs:
### 	Q and E - Switch TileMap
### 	Z and X - Switch tile
### 	Alt     - Load current map
### 	Ctrl    - Save current map
### 	F       - Add filter to listed tiles
### ----------------------------------------------------
extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

onready var Info = {
	ChunkLabel = $UIElements/MC/GC/Info/Chunk,
	ElevationLabel = $UIElements/MC/GC/Info/Elevation,
	CellLabel = $UIElements/MC/GC/Info/Cell,
	Filter = $UIElements/MC/GC/Info/Filter,
}

onready var TileSelect = {
	filter = "",			# Item filter keyword
	allTileMaps = [],		# List of all tilemaps
	tileData = [],			# Data regarding tiles (same order as all tilemaps)
	shownTiles = [],		# List of all show tiles (in TileList)
	TMIndex = 0,			# TileMap index (allTileMaps)
	listIndex = 0,			# Index of selected item
}

onready var States = {
	addingFilter = false,
	isSaving     = false,
	isLoading    = false,
	goto         = false,
}

onready var UIElement = {
	Parent = $UIElements/MC,
	TileScroll = $UIElements/MC/GC/TileScroll,
	TMSelect = $UIElements/MC/GC/TileScroll/TMSelect,
	TileList = $UIElements/MC/GC/TileScroll/ItemList,
	SaveEdit = $UIElements/MC/GC/Info/SaveEdit,
	LoadEdit = $UIElements/MC/GC/Info/LoadEdit,
	FilterEdit = $UIElements/MC/GC/Info/FilterEdit,
	GotoEdit = $UIElements/MC/GC/Info/Goto,
}

var inputActive:bool = true
var UIZone:bool = false

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------
func _input(event: InputEvent) -> void:
	if not inputActive: return
	
	_elevation_input(event)
	_save_input(event)
	_load_input(event)
	_goto_input(event)
	_filter_input(event)
	
	for state in States: if States[state]: return
	
	TM_selection_input(event)
	tile_selection_input(event)
	
	if UIZone: return
	
	update()
	update_MapManager_chunks()
	set_tile_input(event)


func _flag_control(stateName:String) -> bool:
	for state in States: 
		if state == stateName: continue
		if States[state]: return false
	return true


### ----------------------------------------------------
# Selecting TileMap
### ----------------------------------------------------
func TM_selection_input(event: InputEvent):
	if   event.is_action_pressed(DATA.INPUT.MAP["E"]): 
		switch_TM_selection(TileSelect.TMIndex + 1)
	elif event.is_action_pressed(DATA.INPUT.MAP["Q"]): 
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
		
		if TileSelect.filter != "":
			if not TileSelect.filter.to_lower() in tileName.to_lower(): continue
		UIElement.TileList.add_item(tileName,tileTexture,true)
		TileSelect.shownTiles.append([tileName,tileID])
### ----------------------------------------------------


### ----------------------------------------------------
# Selecting Tile
### ----------------------------------------------------
func tile_selection_input(event: InputEvent):
	if   event.is_action_pressed(DATA.INPUT.MAP["X"]):
		switch_tile_selection(TileSelect.listIndex + 1)
	elif event.is_action_pressed(DATA.INPUT.MAP["Z"]): 
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
		if not TileSelect.shownTiles.size() > 0: return # If list empty dont pick
		
		if event.button_mask == BUTTON_MASK_LEFT:  
			var tileID:int = TileSelect.shownTiles[TileSelect.listIndex][1]
			set_selected_tile(tileID)
		if event.button_mask == BUTTON_MASK_RIGHT: 
			set_selected_tile(-1)


func set_selected_tile(tileID:int):
	var tileMap:TileMap = TileSelect.allTileMaps[TileSelect.TMIndex]
	var mousePos:Vector2 = tileMap.world_to_map(get_global_mouse_position())
	var posV3:Vector3 = LibK.Vectors.vec2_vec3(mousePos, $Cam.currentElevation)
	var chunkV3:Vector3 = LibK.Vectors.vec2_vec3(LibK.Vectors.scale_down_vec2(mousePos, DATA.MAP.CHUNK_SIZE), $Cam.currentElevation)
	
	if not chunkV3 in $MapManager.LoadedChunks: return
	var TMName = tileMap.get_name()
	
	if tileID == -1:
		if not SAVE.CurrentSave.remove_tile_on(TMName,posV3):
			Logger.logErr(["Failed to remove tile."],get_stack())
		$MapManager.refresh_tile(posV3)
		return
	
	var tileData = TileData.new(tileID)
	if not SAVE.CurrentSave.set_tile_on(TMName,posV3,tileData):
		Logger.logErr(["Failed to set tile: ",TMName, posV3, tileData], get_stack())
	$MapManager.refresh_tile(posV3)
### ----------------------------------------------------


### ----------------------------------------------------
# Filter Items
### ----------------------------------------------------
func _filter_input(event:InputEvent):
	if not _flag_control("addingFilter"): return
	
	if event.is_action_pressed(DATA.INPUT.MAP["F"]) and not States.addingFilter:
		_show_lineEdit("addingFilter", UIElement.FilterEdit)
	
	if event.is_action_pressed(DATA.INPUT.MAP["ESC"]) and States.addingFilter:
		_hide_lineEdit("addingFilter", UIElement.FilterEdit)


func _on_Filter_text_entered(new_text: String) -> void:
	TileSelect.filter = new_text
	_hide_lineEdit("addingFilter", UIElement.FilterEdit)
	Info.Filter.text = "Filter: " + "\"" + TileSelect.filter + "\""
	switch_TM_selection(0)
### ----------------------------------------------------


### ----------------------------------------------------
# Update chunks
### ----------------------------------------------------

# Renders chunks as in normal game based on camera position (as simulated entity)
func update_MapManager_chunks():
	var camChunk:Vector2 = LibK.Vectors.scale_down_vec2($Cam.global_position, DATA.MAP.CHUNK_SIZE*DATA.MAP.BASE_SCALE)
	var chunksToRender:Array = []
	var posToRender:Array = LibK.Vectors.vec2_get_square(camChunk, 1)
	
	for pos in posToRender:
		chunksToRender.append(LibK.Vectors.vec2_vec3(pos,$Cam.currentElevation))
	
	$MapManager.update_visable_map(chunksToRender, $Cam.currentElevation)
### ----------------------------------------------------


### ----------------------------------------------------
# Save / Load
### ----------------------------------------------------
func _save_input(event:InputEvent) -> void:
	if not _flag_control("isSaving"): return
	
	if event.is_action_pressed(DATA.INPUT.MAP["LCtrl"]) and not States.isSaving:
		_show_lineEdit("isSaving", UIElement.SaveEdit)
	
	if event.is_action_pressed(DATA.INPUT.MAP["ESC"]) and States.isSaving:
		_hide_lineEdit("isSaving", UIElement.SaveEdit)


func _load_input(event:InputEvent) -> void:
	if not _flag_control("isLoading"): return
	
	if event.is_action_pressed(DATA.INPUT.MAP["LAlt"]) and not States.isLoading:
		_show_lineEdit("isLoading", UIElement.LoadEdit)
	
	if event.is_action_pressed(DATA.INPUT.MAP["ESC"]) and States.isLoading:
		_hide_lineEdit("isLoading", UIElement.LoadEdit)


func _on_SaveEdit_text_entered(SaveName: String) -> void:
	if not SAVE.save_CurrentSave(SaveName):
		Logger.logErr(["Failed to save: ", SaveName], get_stack())
	
	_hide_lineEdit("isSaving", UIElement.SaveEdit)


func _on_LoadEdit_text_entered(SaveName: String) -> void:
	if not LibK.Files.file_exist(SAVE.saveFolderDir + SaveName + ".res"):
		Logger.logErr(["Save called: ", SaveName, " doesn't exist!"], get_stack())
		return
	
	if not SAVE.load_CurrentSave(SaveName):
		Logger.logErr(["Failed to load save: ", SaveName], get_stack())
	
	update_MapManager_chunks()
	$MapManager.refresh_all_chunks()
	_hide_lineEdit("isLoading", UIElement.LoadEdit)
### ----------------------------------------------------


### ----------------------------------------------------
# GOTO
### ----------------------------------------------------
func _goto_input(event:InputEvent) -> void:
	if not _flag_control("goto"): return
	
	if event.is_action_pressed(DATA.INPUT.MAP["G"]) and not States.goto:
		_show_lineEdit("goto", UIElement.GotoEdit)
	
	if event.is_action_pressed(DATA.INPUT.MAP["ESC"]) and States.goto:
		_hide_lineEdit("goto", UIElement.GotoEdit)


func _on_GOTO_text_entered(new_text: String) -> void:
	var coords:Array = new_text.split(" ")
	if not coords.size() >= 2: return
	if not coords[0].is_valid_integer() and coords[1].is_valid_integer():
		return
	
	var x:int = int(coords[0]) * DATA.Map.BASE_SCALE
	var y:int = int(coords[1]) * DATA.Map.BASE_SCALE
	$Cam.global_position = Vector2(x,y)
	
	_hide_lineEdit("goto", UIElement.GotoEdit)
### ----------------------------------------------------

### ----------------------------------------------------
# Elevation
### ----------------------------------------------------
func _elevation_input(event:InputEvent):
	if event.is_action_pressed(DATA.INPUT.MAP["-"]):
		change_elevation(-1)
	if event.is_action_pressed(DATA.INPUT.MAP["="]):
		change_elevation(1)


func change_elevation(direction:int):
	$Cam.currentElevation += direction
	Info.ElevationLabel.text = "Elevation: " + str($Cam.currentElevation)
	$MapManager.unload_all_chunks()
### ----------------------------------------------------

### ----------------------------------------------------
# UI Control
### ----------------------------------------------------
func _physics_process(_delta: float) -> void:
	UIZone = LibK.UI.is_mouse_on_ui(UIElement.TileScroll, UIElement.Parent)


func _show_lineEdit(stateName:String, LENode:Control):
	$Cam.inputActive = false
	States[stateName] = true
	LENode.show()
	LENode.grab_focus()


func _hide_lineEdit(stateName:String, LENode:Control):
	$Cam.inputActive = true
	States[stateName] = false
	LENode.hide()
### ----------------------------------------------------
