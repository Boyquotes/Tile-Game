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
		
		var textureBG = load(textureBGPath)
		var textureOutline = load(textureOutlinePath)
		
		for M_TYPE in DATA.Materials.TYPES.values():
			var M_COLOR:Color = DATA.Materials.DB[M_TYPE]["Color"]
			var texture:Texture = _blend_textures(textureBG,textureOutline,M_COLOR)
			var tileName:String = DATA.Materials.TYPES.keys()[M_TYPE] + setName
			var tileMode:int = TileSet.SINGLE_TILE
			if tileType == "Autotile": tileMode = TileSet.AUTO_TILE
			
			tileSet = _add_tile(tileSet, tileName, texture, tileMode, bitmask_flags)
			# ResourceSaver.save("res://Temp/"+str(tileName)+setName+str(tileMode)+".png",texture)
			Logger.logMS(["Added tile type: ",tileName,", to ",setName])
	
	return tileSet


# Adds new tile to a tileset or/and updates it
static func _add_tile(tileSet:TileSet,tName:String, texture:Texture, tileMode:int,
bitmask_flags:Array) -> TileSet:
	# Check if tile exists if not create new
	var tileID:int = tileSet.find_tile_by_name(tName)
	if tileID == -1:
		tileID = LibK.TS._get_next_id(tileSet.get_tiles_ids())
		tileSet.create_tile(tileID)
		Logger.logMS(["Created new tile: ",tName])
	
	# Update tile
	tileSet.tile_set_name(tileID,tName)
	tileSet.tile_set_texture(tileID,texture)
	tileSet.tile_set_tile_mode(tileID,tileMode)
	
	var region:Rect2 = Rect2(0,0,texture.get_width(),texture.get_height())
	tileSet.tile_set_region(tileID,region)
	
	if tileMode==TileSet.AUTO_TILE:
		var size = Vector2(float(texture.get_width())/8,float(texture.get_height())/6)
		tileSet.autotile_set_size(tileID,size)
		tileSet.autotile_set_bitmask_mode(tileID, TileSet.BITMASK_3X3_MINIMAL)
		tileSet = _set_autotile_bitmask(tileSet, tileID, bitmask_flags)
	
	return tileSet


# Blends two separate textures to create one texture
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
			if BGPixel.a != 0: BGPixel = BGPixel.linear_interpolate(addColor,0.4) 
			
			# Put outline on
			var OutlinePixel:Color = OutlineImage.get_pixel(x,y)
			var blendPixel:Color = BGPixel
			if OutlinePixel.a != 0: blendPixel = BGPixel.linear_interpolate(OutlinePixel,1)
			
			blendImage.set_pixel(x,y,blendPixel)
	
	texture.create_from_image(blendImage,0)
	
	return texture


# Adds autotile to an existing TileSet
static func add_autotile(tileSet:TileSet,texture:Texture,
tileSize:Vector2,tileName:String,tileID:int,bitmask_flags:Array) -> TileSet:
	var textureSize:Vector2 = texture.get_size()
	var region = Rect2(0,0,textureSize[0],textureSize[1])
	
	tileSet.create_tile(tileID)
	tileSet.tile_set_name(tileID,tileName)
	tileSet.tile_set_texture(tileID,texture)
	tileSet.tile_set_tile_mode(tileID,TileSet.AUTO_TILE)
	tileSet.autotile_set_bitmask_mode(tileID,TileSet.BITMASK_3X3_MINIMAL)
	tileSet.autotile_set_size(tileID,tileSize)
	tileSet.tile_set_region(tileID,region)
	tileSet = _set_autotile_bitmask(tileSet,tileID,bitmask_flags)
	
	return tileSet


# Adds bitmask to an existing autotile
# You have to add every individual bitmask vector manually
static func _set_autotile_bitmask(tileSet:TileSet,tileID:int,bitmask_flags:Array) -> TileSet:
	var bVectors:Array = []
	var bNums:Array = []
	
	for index in range(bitmask_flags.size()):
		if index%2==0:
			bVectors.append(bitmask_flags[index])
		else:
			bNums.append(bitmask_flags[index])
	
	for index in range(bVectors.size()):
		tileSet.autotile_set_bitmask(tileID,bVectors[index],bNums[index])
	
	return tileSet


# Debug function to print .tres content
static func _get_res_string(res:Resource) -> String:
	var path = "res://Dev Tools/TileSetsSetup/Temp/temp.tres"
	var _result = ResourceSaver.save(path,res)
	var content = LibK.Files.load_res_str(path)
	
	var dir = Directory.new()
	dir.remove(path)
	return content
