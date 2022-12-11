### ----------------------------------------------------
### Function handles all logging procedures
### ----------------------------------------------------
extends Node
class_name Logger

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

# Function takes in message and logs output
static func logMS(message:Array, err:bool = false):
	var output:String = ""
	
	if err: output = "[ERR] "
	else:   output = "[LOG] "
	
	for part in message:
		part = String(part)
		# Modifiers to log
		if "[B]" in part: 
			part = part.replace("[B]","")
			part = part.to_upper()
		if "[TAB]" in part: 
			part = part.replace("[TAB]","")
			output = output.insert(5,"	")
		output += part
	
	print(output)
