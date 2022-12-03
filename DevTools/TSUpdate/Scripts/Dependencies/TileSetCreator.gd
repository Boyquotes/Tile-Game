### ----------------------------------------------------
### Helps with automatic tileset creation
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# Adds autotiles according to types declared in DATA
# data = {Autotile:{setName:setDir}, Single:{setName:setDir}}
static func add_tile_types(tileSet:TileSet, data:Dictionary, bitmask_flags:Array) -> TileSet:
	tileSet = _add_tile_type(tileSet, data, bitmask_flags,"Autotile")
	tileSet = _add_tile_type(tileSet, data, bitmask_flags,"Single")
	
	tileSet = _remove_old_tiles(tileSet)
	
	return tileSet


# Adds all materials to TileSet
static func _add_tile_type(tileSet:TileSet, data:Dictionary, bitmask_flags:Array,
 tileType:String) -> TileSet:
	if not data.has(tileType):
		Logger.logMS(["TileType ",tileType,", doesnt exist in data"])
		return tileSet
	
	for setName in data[tileType]:
		var textureBGPath:String = data[tileType][setName]+"/BG.png"
		if not LibK.Files.file_exist(textureBGPath):
			Logger.logMS(["File doesnt exist (textureBGPath): ",textureBGPath],true)
			continue
		
		var textureOutlinePath:String = data[tileType][setName]+"/Outline.png"
		if not LibK.Files.file_exist(textureOutlinePath):
			Logger.logMS(["File doesnt exist (textureOutlinePath): ",textureOutlinePath],true)
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
			Logger.logMS(["Added tile type: ",tileName,", to ",setName])
	
	return tileSet


# Interpolates BG texture with addColor 20/80
# Puts Outline texture on top of interpolated BG texture
static func _blend_textures(textureBG:Texture,textureOutline:Texture,addColor:Color) -> Texture:
	var texture:ImageTexture = ImageTexture.new()
	if not textureBG.get_size() == textureOutline.get_size():
		Logger.logMS(["Texture outline and bg must be same size: ",textureBG.get_size()," ",textureOutline.get_size()],true)
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


# Removes all non existent material tiles that were previously generated
static func _remove_old_tiles(tileSet:TileSet) -> TileSet:
	var tileNames:Array = LibK.TS.get_tile_names(tileSet)
	var tileIDs:Array = tileSet.get_tiles_ids()
	var tilesToDelete:Array = []
	
	#tileSet = LibK.TS._add_tile(tileSet, "abcd%GEN%", Texture.new(), TileSet.SINGLE_TILE, [])
	
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
		Logger.logMS(["Removed outdated tile: ", rmTN])
	
	return tileSet
