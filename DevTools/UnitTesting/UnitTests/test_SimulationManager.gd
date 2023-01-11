### ----------------------------------------------------
### Unit test for MapManager
### ----------------------------------------------------
extends GutTestLOG

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const _SM = preload("res://Scenes/SimulationManager/MapManager/MapManager.tscn")
var SimulationManager:Node = null

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func before_each():
	SimulationManager = autoqfree(_SM.instance())
	add_child(SimulationManager)

### ----------------------------------------------------
# UnitTests
### ----------------------------------------------------
