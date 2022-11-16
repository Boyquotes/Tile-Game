### ----------------------------------------------------
### Base script attached to every unit test
### ----------------------------------------------------
extends Node2D
class_name UnitTestBase

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

export (Script) var UnitTestLib = preload("res://DevTools/UnitTesting/Scripts/UnitTestLib.gd")

var TestedNode # Scene (Node) That is the root of the testing
var errors:int = 0 # counts and displays number of errors

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### INIT ###
# initialize
func start_test(testedNodeRef):
	TestedNode = testedNodeRef
	
	# Start
	UnitTestLib.announceStart(TestedNode.get_name())
	
	for funcName in _get_method_names():
		Logger.logMS(["Runing test: ",funcName])
		call(funcName)
		Logger.logMS(["Test finished for: ",funcName,"\n"])
	
	# End
	Logger.logMS(["Error number: ", errors])
	UnitTestLib.announceEnd(TestedNode.get_name())


### UTILITY ###
# Gets all function names in this node
const _METHOD_BLACKLIST = ["_init","_ready","_get_method_names","start_test"]
func _get_method_names():
	var methods = []
	for fun in get_method_list():
		if _METHOD_BLACKLIST.has(fun["name"]):
			continue
		if fun["flags"] == METHOD_FLAG_NORMAL + METHOD_FLAG_FROM_SCRIPT:
			methods.append(fun["name"])
	
	return methods
