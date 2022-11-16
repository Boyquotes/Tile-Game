### ----------------------------------------------------
### Runs unit tests
### Usage:
### 1) Specify tested scene path in UNIT_TESTS
### 2) Requires already written unit tests in the UNIT_TESTS_DIR directory
###    UNIT_TESTS_DIR/$(nodeName)/$(nodeNameUT.gd)
### ----------------------------------------------------
extends Node2D

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------
const UNIT_TESTS_DIR = "res://DevTools/UnitTesting/UnitTests/"
const UNIT_TESTS = {
	"MapManager":"res://Scenes/SimulationManager/MapManager/MapManager.tscn",
	"SimulationManager":"res://Scenes/SimulationManager/SimulationManager.tscn",
}

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### INIT ###
func _ready():
	# Starts unit test for a given scene
	start_unit_test("SimulationManager")


### UTILITY ###
# Starts unit test, adds tested node as child
func start_unit_test(testName:String) -> void:
	if not UNIT_TESTS.has(testName):
		Logger.logMS(["Missing testing node called: ", testName], true)
		return
	
	# Load scene
	var scenePath = UNIT_TESTS[testName]
	if not LibK.Files.file_exist(scenePath):
		Logger.logMS(["Unit Test is missing: ", scenePath], true)
		return
	
	var sceneSource = load(scenePath)
	var scene = sceneSource.instance()
	add_child(scene)
	
	# Load unit test
	var UTdir = UNIT_TESTS_DIR + testName + "/" + testName + "UT.gd"
	if not LibK.Files.file_exist(UTdir):
		Logger.logMS(["Unit Test is missing: ", UTdir], true)
		return
	
	var UTScript:Script = load(UTdir)
	var UTNode = Node2D.new()
	UTNode.name = "UnitTestNode"
	UTNode.set_script(UTScript)
	
	# Start test
	UTNode.start_test(scene)
