### ----------------------------------------------------
### Base for custom data types
### Allows for easy data saving
### ----------------------------------------------------

extends Reference
class_name DataType

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

func from_str(s:String):
	return from_array(str2var(s))


func _to_string() -> String:
	return var2str(to_array())


func to_array() -> Array:
	var arr := []
	for propertyInfo in get_script().get_script_property_list():
		arr.append(get(propertyInfo.name))
	return arr


func from_array(arr:Array):
	var index := 0
	for propertyInfo in get_script().get_script_property_list():
		set(propertyInfo.name, arr[index])
		index+=1
	return self
