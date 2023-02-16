### ----------------------------------------------------
### Desc
### ----------------------------------------------------

extends Node2D
class_name GameEntity

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

var MapPosition:Vector3 setget _set_MapPosition

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func _set_MapPosition(posV3:Vector3):
	global_position = LibK.Vectors.vec3_vec2(posV3)
	MapPosition = posV3


func save_entity():
	pass


# Creates a copy of entity from its data string
func from_str(s:String):
	return from_array(str2var(s))

# Creates copy of entity data as string
func _to_string() -> String:
	return var2str(to_array())

# Converts entity data to an array
func to_array() -> Array:
	var arr := []
	for propertyInfo in get_script().get_script_property_list():
		arr.append(get(propertyInfo.name))
	return arr

# Creates copy of entity data as Array
func from_array(arr:Array):
	var index := 0
	for propertyInfo in get_script().get_script_property_list():
		set(propertyInfo.name, arr[index])
		index+=1
	return self