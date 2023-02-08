### ----------------------------------------------------
### Sublib for Vector related functions
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# Function generates array of positions in range of given base position
# Used for getting neighbouring vectors to a given vector
# Ex. drawing range of a weapon on a tilemap, drawing vision
static func vec2_get_square(atPos:Vector2, squareRange:int) -> Array:
	squareRange+=1
	var Square = []
	var squareSideSize=squareRange*2-1
	for x in range(squareSideSize):
		x = x-(squareRange-1)
		for y in range(squareSideSize):
			y = y-(squareRange-1)
			Square.append(Vector2(x,y)+atPos)
	return Square


static func vec3_get_square(atPos:Vector3, squareRange:int, sameLevel:bool) -> Array:
	squareRange+=1
	var Square=[]
	var squareSideSize=squareRange*2-1
	for x in range(squareSideSize):
		x = x-(squareRange-1)
		for y in range(squareSideSize):
			y = y-(squareRange-1)
			if sameLevel:
				Square.append(Vector3(x,y,0) + atPos)
				continue
			for z in range(squareSideSize):
				z = z-(squareRange-1)
				Square.append(Vector3(x,y,z) + atPos)
	return Square


# Removes vectors from array that are too far from a middleV
static func vec_distance_cut(VecArr:Array, middleV, distance:int):
	var result=[]
	for v in VecArr:
		if v.distance_to(middleV)<=(distance-1):
			result.append(v)
	return result


### ----------------------------------------------------
# Conversion Vector2 / Vector3
### ----------------------------------------------------
static func vec2_vec3(v:Vector2, z:int = 0) -> Vector3:
	return Vector3(v.x, v.y, z)
static func vec3_vec2(v:Vector3) -> Vector2:
	return Vector2(v.x, v.y)
### ----------------------------------------------------


### ----------------------------------------------------
# World to x (for Vector3 ommits third value)
### ----------------------------------------------------
static func scale_down_vec2(v:Vector2, scale:int) -> Vector2:
	return Vector2(floor(v[0]/(scale)), floor(v[1]/(scale)))


static func scale_down_vec3(v:Vector3, scale:int) -> Vector3:
	return Vector3(floor(v[0]/(scale)), floor(v[1]/(scale)), v[2])


static func vec2_get_pos_in_chunk(chunkV:Vector2, chunkSize:int) -> Array:
	var packedPositions = []
	for x in range(chunkSize):
		for y in range(chunkSize):
			packedPositions.append(Vector2(int(chunkV[0]*chunkSize + x),
				int(chunkV[1]*chunkSize + y)))
	return packedPositions


static func vec3_get_pos_in_chunk(chunkV:Vector3, chunkSize:int) -> Array:
	var packedPositions = []
	for x in range(chunkSize):
		for y in range(chunkSize):
			packedPositions.append(Vector3(int(chunkV[0]*chunkSize + x),
				int(chunkV[1]*chunkSize + y), chunkV[2]))
	return packedPositions
### ----------------------------------------------------
