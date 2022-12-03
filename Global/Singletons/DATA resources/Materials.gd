### ----------------------------------------------------
### Singleton subscript used for storing data regarding tile materials
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

# https://www.rapidtables.com/web/color/RGB_Color.html
enum TYPES {WoodenPlank,Stone,Steel,Dirt,Grass,DarkGrass}
const DB:Dictionary = {
	TYPES.WoodenPlank:{"Color":Color('#816109')},
	TYPES.Stone: 	  {"Color":Color('#444444')},
	TYPES.Steel: 	  {"Color":Color('#708090')},
	TYPES.Dirt:  	  {"Color":Color('#483D8B')},
	TYPES.Grass: 	  {"Color":Color('#228B22')},
	TYPES.DarkGrass:  {"Color":Color('#006400')},
}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------
