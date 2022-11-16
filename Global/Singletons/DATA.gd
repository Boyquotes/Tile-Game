### ----------------------------------------------------
### Singleton for storing game data
### Stores general data like seed for map gen, chunk size ect
### All data modules are preloaded as scripts
### ----------------------------------------------------
tool
extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

### SCRIPTS ###
const Map:Script = preload("res://Global/Singletons/DATA resources/Map.gd")
const Materials:Script = preload("res://Global/Singletons/DATA resources/Materials.gd")
