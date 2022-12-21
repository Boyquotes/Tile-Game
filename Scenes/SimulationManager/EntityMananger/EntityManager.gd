### ----------------------------------------------------
### Has direct access to all ingame entities
### ----------------------------------------------------
extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var Player:Node2D # Just to have direct access to player

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# LOAD ENTITIES #
# Load simulated entities form a save file
func load_simulated_entities(EDataSim:Dictionary) -> bool:
	for packedPos in EDataSim:
		if not _load_entity(EDataSim[packedPos], packedPos):
			Logger.logErr(["Failed to load entity."], get_stack())
	
	if Player == null:
		Logger.logErr(["Player does not exist in this save file!"], get_stack())
		return false
	
	return true


# Updates all not all simulated entities that got into render distance
func update_noSim_entities(renderedEntities:Dictionary, simulatedChunks:Array):
	# Load all new ones
	for packedPos in renderedEntities:
		if not _load_entity(renderedEntities[packedPos], packedPos):
			Logger.logErr(["Failed to load entity."], get_stack())
	
	# Unload old ones
	for Entity in get_children():
		if Entity.get("isSimulated") == null:
			Logger.logErr(["Entity: ", Entity.get_name(),", has no variable called 'isSimulated'."], get_stack())
			continue
		
		# Unload all not simulated entities that are beyond render distance
		if Entity.isSimulated:
			continue
		
		var packedPos = [Entity.mapPosition,Entity.elevationLevel]
		if not simulatedChunks.has(packedPos):
			Entity.save_entity_data()
			Entity.queue_free()
	
	return true


# Loads a given entity
func _load_entity(EData:Dictionary, packedPos:Array) -> bool:
	var scenePath = EData["ScenePath"]
	var Entity = load(scenePath).instance()
	if Entity == null:
		Logger.logErr(["Entity scene: ",scenePath,", does not exist."], get_stack())
		return false
	
	# Loading entity into the map
	add_child(Entity)
	Entity.load_entity_data(EData,packedPos)
	
	Logger.logMS(["Loaded entity called: ",Entity.get_name()])
	
	if Entity.get_name() == "Player":
		Player = Entity
	return true


# GET ENTITIES #
# Returns all simulated entities
func get_simulated_entities() -> Array:
	var SimEntities = []
	
	for Entity in get_children():
		if Entity.get("isSimulated") == null:
			Logger.logErr(["Entity: ", Entity.get_name(),", has no variable called 'isSimulated'."], get_stack())
			continue
		
		if Entity.isSimulated:
			SimEntities.append(Entity)
	
	return SimEntities
