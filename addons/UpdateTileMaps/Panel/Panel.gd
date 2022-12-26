### ----------------------------------------------------
### Desc
### ----------------------------------------------------
tool
extends VBoxContainer

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var Errors:int = 0

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _ready() -> void:
	$Output.set_scroll_follow(true)
	$UpdateTileMaps.connect("logMessage",self,"log_to_console")
	$UpdateTileMaps/ScriptsGenerator.connect("logMessage",self,"log_to_console")


### ----------------------------------------------------
# Console
### ----------------------------------------------------

func log_to_console(message:Array, isErr:bool):
	var info:String = "[color=white]"
	if isErr: 
		info = "[color=red]"
		Errors += 1
	
	message.push_front(info)
	
	var output:String = ""
	for part in message:
		part = String(part)
		output += part
	
	output += "[/color]"
	$Output.bbcode_text += output + "\n"

### ----------------------------------------------------

### ----------------------------------------------------
# Signals
### ----------------------------------------------------

func _on_Button_pressed() -> void:
	$Output.bbcode_text = ""  # Clear console
	$UpdateTileMaps.start_script()
	
	var text:String = "\n[color=lime]"
	if Errors != 0: text = "\n[color=red]"
	
	log_to_console([text + "Update finished, errors: ", Errors], false)
	Errors = 0
### ----------------------------------------------------
