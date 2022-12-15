### ----------------------------------------------------
### Function handles all logging procedures
### ----------------------------------------------------
extends Node
class_name Logger

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

static func logMS(message:Array):
	message.push_front("[LOG] ")
	_format_LOG(message)


# Format:
# logErr(["This is an error message], get_stack())
static func logErr(message:Array, frame:Array):
	var errInfo:String = "[ERR] " + "Line:" + str(frame[0]["line"]) + ", Script:" + frame[0]["source"] + ", Function:" + frame[0]["function"]
	_format_LOG(errInfo)
	
	message.push_front("[ERR] ")
	_format_LOG(message)
	

static func _format_LOG(message):
	var output:String = ""
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
