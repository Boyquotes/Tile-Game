### ----------------------------------------------------
### Sublib for tileset functions
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# returns tile names in the same order as IDs
static func get_tile_names(tileSet:TileSet) -> Array:
	var tileNames = []
	for id in tileSet.get_tiles_ids(): 
		tileNames.append(tileSet.tile_get_name(id))
	return tileNames


# returns only autotile IDs
static func get_autotile_ids(tileSet:TileSet) -> Array:
	var autotileIDs = []
	
	var tileIDs = tileSet.get_tiles_ids()
	for tileID in tileIDs:
		if tileSet.tile_get_tile_mode (tileID) == TileSet.AUTO_TILE:
			autotileIDs.append(tileID)
	
	return autotileIDs


# Returns next not used ID in TileSet
# Examples:
# IN: [0,1,2,3,4]  | IN: [0,1,3,4]
# OUT: 5           | OUT: 2 
static func _get_next_id(tileIDs:Array) -> int:
	var nextID:int = tileIDs.size()
	
	for id in range(tileIDs.size()):
		if not id in tileIDs:
			nextID = id
			break
	
	return nextID


# Adds new tile to a tileset or/and updates it
static func _add_tile(tileSet:TileSet,tName:String, texture:Texture, tileMode:int,
bitmask_flags:Array) -> TileSet:
	# Check if tile exists if not create new
	var tileID:int = tileSet.find_tile_by_name(tName)
	if tileID == -1:
		tileID = _get_next_id(tileSet.get_tiles_ids())
		tileSet.create_tile(tileID)
	
	# Update tile
	tileSet.tile_set_name(tileID,tName)
	tileSet.tile_set_texture(tileID,texture)
	tileSet.tile_set_tile_mode(tileID,tileMode)
	
	var region:Rect2 = Rect2(0,0,texture.get_width(),texture.get_height())
	tileSet.tile_set_region(tileID,region)
	
	# Autotile is updated based on predetermined autotile png size
	if tileMode==TileSet.AUTO_TILE:
		var size = Vector2(float(texture.get_width())/8,float(texture.get_height())/6)
		tileSet.autotile_set_size(tileID,size)
		tileSet.autotile_set_bitmask_mode(tileID, TileSet.BITMASK_3X3_MINIMAL)
		tileSet = _set_autotile_bitmask(tileSet, tileID, bitmask_flags)
	
	return tileSet


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
# NOTE: Format is the same as in the .tres file
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


# Gets tile texture from TileSet
static func get_tile_texture(tileID:int, tileSet:TileSet) -> Texture:
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


static func get_tile_names_and_IDs(tileSet:TileSet) -> Array:
	var tileList:Array = []
	for tileID in tileSet.get_tiles_ids():
		tileList.append([tileSet.tile_get_name(tileID), tileID])
	return tileList


static func get_tile_on_pos(pos:Vector2) -> Vector2:
	var x = floor( pos[0]/(DATA.TILEMAPS.BASE_SCALE) )
	var y = floor( pos[1]/(DATA.TILEMAPS.BASE_SCALE) )
	
	return Vector2(x,y)
