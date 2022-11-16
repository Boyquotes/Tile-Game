### ----------------------------------------------------
### Singleton for globally accessing nodes.
### 1) When trying to access non existing node null is returned.
### 2) All nodes accessing this singleton should have built in system
###    of avoiding errors (default values).
### ----------------------------------------------------
extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

onready var SimulationManager: Node2D setget _set_simManager, get_simManager

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### SETGET ###
func _set_simManager(_node:Node2D):
	push_error("Tried to overwrite SimulationManager!")
	return


# Returns SimulationManager node or null
func get_simManager():
	if SimulationManager!=null:
		return SimulationManager
	
	var rootNodes = get_tree().root.get_children()
	
	for rootNode in rootNodes:
		if rootNode.get_name() == "SimulationManager":
			SimulationManager = rootNode
		else:
			SimulationManager = rootNode.find_node("SimulationManager")
	
	if SimulationManager == null:
		Logger.logMS(["Unable to find SimulationManager."],true)
	
	return SimulationManager
