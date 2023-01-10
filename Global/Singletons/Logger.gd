### ----------------------------------------------------
### Function handles all logging procedures
### ----------------------------------------------------

extends Node

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var logTime = false

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _enter_tree() -> void:
	draw_line(false)
	logMS(["LOG SESSION START"], false)
	logMS(["Platform: ", OS.get_name()], false)
	logMS([get_date(), get_time()], false)
	draw_line(false)


func draw_line(logIndicator:bool = true) -> void:
	logMS(["-----------------------------------------"], logIndicator)


func get_date() -> String:
	var dateDict := OS.get_date()
	var day:String   = str(dateDict.day)
	var month:String = str(dateDict.month)
	if day.length() == 1: day = "0" + day
	if month.length() == 1: month = "0" + month
	return "[" + day + ":" + month + ":" + str(dateDict.year) + "] "


func get_time() -> String:
	var timeDict := OS.get_time()
	var minute:String = str(timeDict.minute)
	var second:String = str(timeDict.second)
	if minute.length() == 1: minute = "0" + minute
	if second.length() == 1: second = "0" + second
	return "[" + str(timeDict.hour) + ":" + minute + ":" + second + "] "


func logMS(message:Array, logIndicator = true):
	if logTime: message.push_front(get_time())
	
	if logIndicator: message.push_front("[LOG] ")
	_format_LOG(message)


# Format:
# logErr(["This is an error message], get_stack())
func logErr(message:Array, frame:Array):
	if not frame.empty():
		message.push_front("[L:" + str(frame[0]["line"]) + ", S:" + frame[0]["source"] + ", F:" + frame[0]["function"] +"] ")
	if logTime: message.push_front(get_time())
	
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
