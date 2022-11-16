### ----------------------------------------------------
### Function handles all logging procedures
### ----------------------------------------------------
extends Node
class_name Logger

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# Function takes in message and logs output
static func logMS(message:Array,err:bool = false):
	var output:String = ""
	if err:
		output += "!ERROR! - "
	
	for part in message:
		output += String(part)
	
	# Print to console
	print(output)
	# TODO: Add possibility of saving to file
