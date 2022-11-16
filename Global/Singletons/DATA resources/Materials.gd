### ----------------------------------------------------
### Singleton subscript used for storing data regarding tile materials
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

enum TYPES {Wood,Stone,Metal,Dirt}
const DB:Dictionary = {
	TYPES.Wood:{"Color":Color.peru},
	TYPES.Stone:{"Color":Color.dimgray},
	TYPES.Metal:{"Color":Color.cornflower},
	TYPES.Dirt:{"Color":Color.slateblue},
}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------
