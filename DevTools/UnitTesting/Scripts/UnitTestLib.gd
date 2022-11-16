### ----------------------------------------------------
### Library of functions used in unit tests
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### DECORATING ###
static func announceStart(sceneName:String):
	Logger.logMS(["-----------------------------------------------"])
	Logger.logMS(["UNIT TEST STATED FOR: ",sceneName,"\n"])


static func announceEnd(sceneName:String):
	Logger.logMS(["UNIT TEST ENDED FOR: ",sceneName])
	Logger.logMS(["-----------------------------------------------\n"])
	

### ASSERT EQUAL ###
# Assert equal for simple variables
static func asserteq(var1,var2,funcName:String) -> int:
	if var1 != var2:
		Logger.logMS(["ERROR asserteq! In: ",funcName,", Values are not equal: ","(",var1," != ", var2,")"], true)
		return 1
	return 0


# Assert equal for dicts
static func asserteqDict(dict1:Dictionary,dict2:Dictionary,funcName:String) -> int:
	if dict1.size() != dict2.size():
		Logger.logMS(["ERROR asserteq! In: ",funcName,", Dict size differs: ","(",dict1.size()," != ", dict2.size(),")"], true)
		return 1
	
	for key in dict1:
		if not dict2.has(key):
			Logger.logMS(["ERROR asserteq! In: ",funcName,", Second dict missing key: ",key], true)
			return 1
	
	for key in dict2:
		if not dict1.has(key):
			Logger.logMS(["ERROR asserteq! In: ",funcName,", First dict missing key: ",key], true)
			return 1
	return 0


# Assert true
static func assertT(state:bool, funcName:String, testName:String) -> int:
	if not state:
		Logger.logMS(["ERROR assertT! In: ",funcName,", assertion failed: ",testName], true)
		return 1
	return 0
