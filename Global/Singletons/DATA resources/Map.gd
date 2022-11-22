### ----------------------------------------------------
### Singleton subscript for storing map data
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const CHUNK_SIZE = 8 # Keep it 2^x (min 8,max 32 - for both performance and drawing reasons)

const BASE_SCALE = 16
export var WALL_PIXEL:int = BASE_SCALE * 1
export var ENV_PIXEL:int = BASE_SCALE * 1
export var ENTITY_PIXEL:int = BASE_SCALE * 2

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# TILESET SYSTEMS #
# Outputs tile positions inside a chunk
static func GET_CHUNK_TILE_POSITIONS(chunkPos:Vector2) -> Array:
	var tilePositions = []
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var tileX
			var tileY
			tileX = chunkPos[0]*CHUNK_SIZE + x
			tileY = chunkPos[1]*CHUNK_SIZE + y 
			
			var tilePos = Vector2(int(tileX),int(tileY)) 
			tilePositions.append(tilePos)
	
	return tilePositions


# Returns chunk position of given tile
# isMap bool defines if given position is a tilemap tile or real world position
static func GET_CHUNK_ON_POSITION(pos:Vector2,isMap:bool = true) -> Vector2:
	var chunkMultiplier:int = 1
	if not isMap:
		chunkMultiplier = DATA.Map.BASE_SCALE
	
	var x = floor( pos[0]/(CHUNK_SIZE*chunkMultiplier) )
	var y = floor( pos[1]/(CHUNK_SIZE*chunkMultiplier) )
	
	return Vector2(x,y)


static func GET_TILE_ON_POSITION(pos:Vector2) -> Vector2:
	var x = floor( pos[0]/(DATA.Map.BASE_SCALE) )
	var y = floor( pos[1]/(DATA.Map.BASE_SCALE) )
	
	return Vector2(x,y)
