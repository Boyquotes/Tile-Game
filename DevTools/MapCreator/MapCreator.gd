### ----------------------------------------------------
### Generates an empty map template for tests
### ----------------------------------------------------
extends Script

### ----------------------------------------------------
# VARIABLES
### ----------------------------------------------------

const SaveFolderPath = "res://Resources/SaveData/SavedMaps/"

### ----------------------------------------------------
# FUNCTIONS
### ----------------------------------------------------

### GENERATION ###
static func generate_map_template(mapName:String) -> bool:
	var saveData = SaveDataRes.new()
	saveData.SaveName = mapName
	
	_add_sim_entity(saveData, [Vector2(0, 0), 0], "res://Resources/Entities/Player/Player.tscn")
	
	saveData.MapData.TData["WallFloor"] = {}
	saveData.MapData.TDataLog= {["GrassFloor","WallFloor"]:1}
	
	for x in range(32):
		for y in range(32):
			saveData.MapData.TData["WallFloor"][[Vector2(x,y),0]] = {
			"tileName":"GrassFloor",
			"tileID":1}
	
	return generate_SaveData(saveData)


static func _add_sim_entity(saveData:SaveDataRes,packedPos:Array,
scenePath:String):
	var data = saveData.EntityData.pack_data(scenePath)
	saveData.EntityData.EDataSim[packedPos] = data


### SAVE ###
static func generate_SaveData(saveData:SaveDataRes) -> bool:
	var path = SaveFolderPath + saveData.SaveName + ".res"
	var result = ResourceSaver.save(path,saveData,ResourceSaver.FLAG_COMPRESS)
	Logger.logMS(["Generated save file: ", saveData.SaveName])
	
	return (result == 0)
