### ----------------------------------------------------
### Helps with automatic tileset creation based on materials in DATA.gd singleton
### Short description:
### 	Every tile consists of Outline.png and BG.png
### 	BGs color is shifted to match material color
### 	BG is put at the back and Outline on top
### 	Resulting texture is added as a tile
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### ----------------------------------------------------
# Adding tile types
### ----------------------------------------------------

# Adds autotiles according to types declared in DATA
# data = {Autotile:{setName:setDir}, Single:{setName:setDir}}
static func add_tile_types(tileSet:TileSet, data:Dictionary, bitmask_flags:Array) -> TileSet:
	if not DATA.Materials.CHECK_TYPES():
		Logger.logErr(["[B]update terminated"], get_stack())
		return tileSet
	
	Logger.logMS(["[TAB][B]< Adding tile types"])
	tileSet = _add_tile_type(tileSet, data, bitmask_flags,"Autotile")
	tileSet = _add_tile_type(tileSet, data, bitmask_flags,"Single")
	Logger.logMS(["[TAB][B]> Adding tile types"])
	
	Logger.logMS(["[TAB][B]< Removing outdated tiles"])
	tileSet = _remove_old_tiles(tileSet)
	Logger.logMS(["[TAB][B]> Removing outdated tiles"])
	
	return tileSet


# Adds all materials to TileSet
static func _add_tile_type(tileSet:TileSet, data:Dictionary, bitmask_flags:Array,
 tileType:String) -> TileSet:
	if not data.has(tileType):
		Logger.logMS(["[TAB]TileType ",tileType,", doesnt exist in data"])
		return tileSet
	
	for setName in data[tileType]:
		var textureBGPath:String = data[tileType][setName]+"/BG.png"
		if not LibK.Files.file_exist(textureBGPath):
			Logger.logErr(["[TAB]File doesnt exist (textureBGPath): ",textureBGPath], get_stack())
			continue
		
		var textureOutlinePath:String = data[tileType][setName]+"/Outline.png"
		if not LibK.Files.file_exist(textureOutlinePath):
			Logger.logErr(["[TAB]File doesnt exist (textureOutlinePath): ",textureOutlinePath], get_stack())
			continue
		
		var textureBG:Texture = load(textureBGPath)
		var textureOutline:Texture = load(textureOutlinePath)
		
		for M_TYPE in DATA.Materials.TYPES.values():
			var M_COLOR:Color = DATA.Materials.DB[M_TYPE]["Color"]
			var texture:Texture = _blend_textures(textureBG,textureOutline,M_COLOR)
			var tileName:String = DATA.Materials.TYPES.keys()[M_TYPE] + setName + DATA.GENERATED_TAG
			var tileMode:int = TileSet.SINGLE_TILE
			if tileType == "Autotile": tileMode = TileSet.AUTO_TILE
			
			tileSet = LibK.TS._add_tile(tileSet, tileName, texture, tileMode, bitmask_flags)
			Logger.logMS(["[TAB]Added tile: ",tileName,", to ",setName])
	
	return tileSet
### ----------------------------------------------------

### ----------------------------------------------------
# Layering textures
### ----------------------------------------------------

# Interpolates BG texture with addColor 20/80
# Puts Outline texture on top of interpolated BG texture
static func _blend_textures(textureBG:Texture,textureOutline:Texture,addColor:Color) -> Texture:
	var texture:ImageTexture = ImageTexture.new()
	if not textureBG.get_size() == textureOutline.get_size():
		Logger.logErr(["[TAB]Texture outline and bg must be same size: ",textureBG.get_size()," ",textureOutline.get_size()], get_stack())
		return texture
	
	var BGImage:Image = textureBG.get_data()
	var OutlineImage:Image = textureOutline.get_data()
	var blendImage:Image = Image.new()
	
	blendImage.create(textureBG.get_width(),textureBG.get_height(),false,Image.FORMAT_RGBA8)
	
	blendImage.lock()
	OutlineImage.lock()
	BGImage.lock()
	
	for x in range(BGImage.get_width()):
		for y in range(BGImage.get_height()):
			# Interpolate bg with addColor
			var BGPixel:Color = BGImage.get_pixel(x,y)
			if BGPixel.a != 0: BGPixel = BGPixel.linear_interpolate(addColor,0.5) 
			
			# Put outline on
			var OutlinePixel:Color = OutlineImage.get_pixel(x,y)
			var blendPixel:Color = BGPixel
			if OutlinePixel.a != 0: blendPixel = BGPixel.linear_interpolate(OutlinePixel,1)
			
			blendImage.set_pixel(x,y,blendPixel)
	
	texture.create_from_image(blendImage,0)
	
	return texture
### ----------------------------------------------------

### ----------------------------------------------------
# Removing old tiles
### ----------------------------------------------------

# Removes all non existent material tiles that were previously generated
static func _remove_old_tiles(tileSet:TileSet) -> TileSet:
	var tileNames:Array = LibK.TS.get_tile_names(tileSet)
	var tileIDs:Array = tileSet.get_tiles_ids()
	var tilesToDelete:Array = []
	
	for index in range(tileIDs.size()):
		var tileName:String = tileNames[index]
		var tileID:int = tileIDs[index]
		
		# Only check for generated tiles
		if not DATA.GENERATED_TAG in tileName:
			continue
		
		# Delete outdated tiles
		var isIn:bool = false
		for materialName in DATA.Materials.TYPES.keys():
			if materialName in tileName:
				isIn = true
		
		if not isIn:
			tilesToDelete.append(tileID)
	
	for tileID in tilesToDelete:
		var rmTN:String = tileSet.tile_get_name(tileID)
		tileSet.remove_tile(tileID)
		Logger.logMS(["[TAB]Removed outdated tile: ", rmTN])
	
	return tileSet
### ----------------------------------------------------
