### ----------------------------------------------------
### Desc
### ----------------------------------------------------
tool
extends VBoxContainer

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const UPDATE_TILEMAPS = preload("res://addons/UpdateTileMaps/Panel/Scripts/UpdateTileMaps.gd")
var Errors:int = 0

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _ready() -> void:
	$Output.set_scroll_follow(true)

func log_to_console(message:Array, isErr:bool):
	var info:String = "[color=white]"
	if isErr: 
		info = "[color=red]"
		Errors += 1
	message.push_front(info)
	var output:String = ""
	for part in message:
		output += String(part)
	
	output += "[/color]"
	$Output.bbcode_text += output + "\n"

func _on_Button_pressed() -> void:
	$Output.bbcode_text = ""  # Clear console
	UPDATE_TILEMAPS.start_script(funcref(self, "log_to_console"))
	var text:String = "\n[color=lime]"
	if Errors != 0: text = "\n[color=red]"
	log_to_console([text + "Update finished, errors: ", Errors], false)
	Errors = 0
