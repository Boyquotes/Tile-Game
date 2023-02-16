### ----------------------------------------------------
### Base for custom data types
### Allows for easy data saving
### ----------------------------------------------------

extends Reference
class_name DataType

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------


# Creates a copy of DataType from its data string
func from_str(s:String):
	return from_array(str2var(s))

# Creates copy of DataType data as string
func _to_string() -> String:
	return var2str(to_array())

# Converts DataType data to an array
func to_array() -> Array:
	var arr := []
	for propertyInfo in get_script().get_script_property_list():
		arr.append(get(propertyInfo.name))
	return arr

# Creates copy of DataType data as Array
func from_array(arr:Array):
	var index := 0
	for propertyInfo in get_script().get_script_property_list():
		set(propertyInfo.name, arr[index])
		index+=1
	return self
