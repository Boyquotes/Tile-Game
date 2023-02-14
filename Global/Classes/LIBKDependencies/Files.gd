### ----------------------------------------------------
### Sublib for file related actions
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const FILE_NEW_LINE = "\n"
const FILE_SKIP_LINE = "\n\n"
const FILE_TAB = "\t"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### ----------------------------------------------------
# Resources
### ----------------------------------------------------

# Saving resource from string
static func save_res_str(content:String,path:String) -> void:
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(content)
	file.close()


# Loading resource as string
static func load_res_str(path:String) -> String:
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content

### ----------------------------------------------------
# Directory / Files
### ----------------------------------------------------


static func copy_file(from:String, to:String) -> int:
	return Directory.new().copy(from,to)

static func create_empty_file(path:String) -> int:
	var file := File.new()
	var result := file.open(path, File.WRITE)
	file.close()
	return result

static func delete_file(path:String) -> int:
	return Directory.new().remove(path)

# Returns [ [filepath, filename], ... ]
static func get_file_list_at_dir(path:String) -> Array:
	var dir = Directory.new()
	var fileList = []
	
	if not dir.open(path) == OK:
		return []
	
	dir.list_dir_begin(true,true)
	var fileName = dir.get_next()
	while fileName != "":
		if not "import" in fileName:
			if path[path.length()-1] != "/":
				path += "/"
			fileList.append([path + fileName, fileName])
		fileName = dir.get_next()
	dir.list_dir_end()
	
	return fileList

static func file_exist(filePath:String) -> bool:
	return Directory.new().file_exists(filePath)

static func dir_exist(dirPath:String) -> bool:
	return Directory.new().dir_exists(dirPath)


### ----------------------------------------------------
# MISC
### ----------------------------------------------------


# Returns image size as array [width,height]
static func get_png_size(path:String) -> Array:
	var image = Image.new().load(path)
	return [image.get_width(),image.get_height()]

# Returns a part of string from a given startString (included),
# to endString (included)
static func get_string_fromEnd_toStart(source:String,startStr:String,endStr:String) -> String:
	var startIndex = source.find(startStr)
	startIndex = startIndex + startStr.length()
	var endIndex = source.rfind(endStr)
	
	var span = endIndex - startIndex
	var result = source.substr(startIndex,span)
	
	return result


