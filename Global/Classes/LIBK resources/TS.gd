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


# returns autotile IDs
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
