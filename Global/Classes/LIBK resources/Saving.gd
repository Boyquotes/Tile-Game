### ----------------------------------------------------
### Sublib for saving related tasks
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

static func saveResource(path:String, res:Resource) -> String:
	var result:int = ResourceSaver.save(path, res)
	if result == 0:
		return "[SAVE OK] Saved resource to path: " + path
	return "[SAVE ERR] Unable to save resource to path: " + path + ", err code: " + str(result)
