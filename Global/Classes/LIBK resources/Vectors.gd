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
static func GET_POS_RANGE_V2(squareRange:int,atPos:Vector2,cutEdges:bool) -> Array:
	var squareRaw=[]
	squareRange+=1
	var squareSideSize=squareRange*2-1
	
	for x in range(squareSideSize):
		x=x-(squareRange-1)
		for y in range(squareSideSize):
			y=y-(squareRange-1)
			squareRaw.append(Vector2(x,y)+atPos)
	
	# Get rid of sides not in range if true
	var finalSquare=[]
	if cutEdges:
		for pos in squareRaw:
			if pos.distance_to(atPos)<=(squareRange-1):
				finalSquare.append(pos)
	else:
		finalSquare=squareRaw
	
	return finalSquare
