### ----------------------------------------------------
### Contains tools for creating scripts or tilesets automatically
### ----------------------------------------------------
extends Script
class_name DevCreator

# Creating scripts
const ScriptC:Script = preload("res://DevTools/DevCreator/ScriptCreator/ScriptCreator.gd")

# Creating tilesets
const TileSetC:Script = preload("res://DevTools/DevCreator/TileSetCreator/TileSetCreator.gd")
