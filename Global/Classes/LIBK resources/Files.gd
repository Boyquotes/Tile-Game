### ----------------------------------------------------
### Sublib for file related actions
### ----------------------------------------------------
extends Resource

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const FILE_NEW_LINE = "\n"
const FILE_SKIP_LINE = "\n\n"
const FILE_TAB = "\t"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### RESOURCES ###
# Saving resource from string
static func save_res_str(content:String,path:String):
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


### MISC ###
# Returns all file directories in a given directory
static func get_file_list(path:String,getDirs:bool=false) -> Array:
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
			
			if getDirs:
				fileList.append(path + fileName)
			else:
				fileList.append(fileName)
		fileName = dir.get_next()
	dir.list_dir_end()
	
	return fileList

# Returns image size as array [width,height]
static func get_png_size(path:String) -> Array:
	var image = Image.new()
	image.load(path)
	
	var size = [image.get_width(),image.get_height()]
	return size


# Returns a part of string from a given startString (included),
# to endString (included)
static func get_string_fromEnd_toStart(source:String,startStr:String,endStr:String) -> String:
	var startIndex = source.find(startStr)
	startIndex = startIndex + startStr.length()
	var endIndex = source.rfind(endStr)
	
	var span = endIndex - startIndex
	var result = source.substr(startIndex,span)
	
	return result


static func file_exist(filePath:String) -> bool:
	var directory = Directory.new();
	return directory.file_exists(filePath)


static func dir_exist(dirPath:String) -> bool:
	var directory = Directory.new();
	return directory.dir_exists(dirPath)
