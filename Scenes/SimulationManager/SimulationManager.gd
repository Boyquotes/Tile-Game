### ----------------------------------------------------
### Decides what chunks of the map are meant to be simulated in the game
### ----------------------------------------------------

extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const SIM_RANGE = 1

# [ Vector3,... ]
var SimulatedChunks:Array

# [ GameEntity,... ]
var SimulatedEntities:Array

# Focus of both camera and rendering tilemap 
var GameFocusEntity:GameEntity

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _ready() -> void:
	start_simulation("test")


func start_simulation(mapName:String) -> bool:
	var isOK:bool = true
	
	# Add dummy entity
	var DummyEntity := GameEntity.new()
	SimulatedEntities.append(DummyEntity) 
	GameFocusEntity = DummyEntity

	update_simulation()
	
	return isOK


func update_simulation() -> void:
	_update_simulated_chunks()
	$MapManager.update_visable_map(SimulatedChunks)


func _update_simulated_chunks() -> void:
	for entity in SimulatedEntities:
		var sqrRange := LibK.Vectors.vec3_get_square(
			entity.MapPosition, SIM_RANGE, true)
		for posV3 in sqrRange:
			if SimulatedChunks.has(posV3): continue
			SimulatedChunks.append(posV3)
