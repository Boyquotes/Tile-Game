### ----------------------------------------------------
### Singleton subscript used for storing data regarding tile materials
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

enum TYPES {Wood,Stone,Metal,Dirt,Grass,DarkGrass}
const DB:Dictionary = {
	TYPES.Wood:  	{"Color":Color.coral},
	TYPES.Stone: 	{"Color":Color.dimgray},
	TYPES.Metal: 	{"Color":Color.cornflower},
	TYPES.Dirt:  	{"Color":Color.indigo},
	TYPES.Grass: 	{"Color":Color.forestgreen},
	TYPES.DarkGrass:{"Color":Color.seagreen},
}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------
