### ----------------------------------------------------
### Helps with automatic script creation
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### VARIABLE / CONST ###
# Function generates multiple variables or const depending on input
static func create_variables_str(types:Array,varNames:Array,values:Array,marker:String) -> String:
	var result:String = ""
	var check = varNames.size() == values.size() and varNames.size() == types.size()
	assert(check,"Amount of types, varNames and values must be the same")
	
	result += get_marker_str(marker,false)
	for index in range (varNames.size()):
		result+=get_var_str(types[index],varNames[index],values[index])+"\n"
	result += get_marker_str(marker,true)
	
	return result


# Function generates single variable or const depending on input
static func get_var_str(varType:String,varName:String,value) -> String:
	var result = varType + " " + varName + " = " + var2str(value)
	return result

### ENUM ###
# Function generates multiple enums depending on input
# Note that itemNames should be an array of arrays
static func create_enums_str(enumNames:Array,itemNames:Array,marker:String) -> String:
	var result:String = ""
	var check = enumNames.size() == itemNames.size()
	assert(check,"Amount of enumNames and itemNames must be the same")
	
	result += get_marker_str(marker,false)
	for index in range (enumNames.size()):
		result += get_enum_str(enumNames[index],itemNames[index]) + "\n"
	result += get_marker_str(marker,true)
	
	return result


# Function generates single enum depending on input
static func get_enum_str(enumName:String,items:Array) -> String:
	var result = "enum " + enumName + " {"
	for item in items: result += item + ","
	result += "}"
	return result


### MARKER ###
# Creates marker in a script
static func get_marker_str(markerName:String,end:bool) -> String:
	var result = "### " + markerName.to_upper() + " START\n"
	if end:
		result = "### " + markerName.to_upper() + " END\n"
	return result


# Returns a part of script that was inside a marker
static func get_str_with_marker(source:String,markerName:String) -> String:
	var markerStart = get_marker_str(markerName,false)
	var markerEnd = get_marker_str(markerName,true)
	
	var startIndex = source.find(markerStart)
	startIndex = startIndex + markerStart.length()
	
	var endIndex = source.find(markerEnd)
	
	var span = endIndex - startIndex
	var result = source.substr(startIndex,span)
	
	return result