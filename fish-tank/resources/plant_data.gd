@tool
extends Resource
class_name PlantData

@export_storage var plant_stages : Array[String] = []
@export_storage var stage_ticks : Array[int] = []
@export_storage var stage_nutrients : Array[Dictionary] = []
@export_storage var environment_nutrient : Array[Dictionary] = []

@export var price : int = 0
@export_range(0, 40, 1) var stages : int = 1 :
	set(value):
		stages = value
		while plant_stages.size() > stages:
			plant_stages.pop_back()
			stage_nutrients.pop_back()
			environment_nutrient.pop_back()
			stage_ticks.pop_back()
		while plant_stages.size() < stages:
			plant_stages.append("<null>")
			stage_ticks.append(1)
			environment_nutrient.append({})
			stage_nutrients.append({})
		notify_property_list_changed()

@export_group("Plant Stages")

func _get_property_list() -> Array[Dictionary]:
	var properties : Array[Dictionary] = []
	for i in plant_stages.size():
		properties.append(add_subgroup("Stage %s" % i)) 
		properties.append(add_property_enum_from_dir("plant_model %s" % i, TYPE_STRING, PROPERTY_USAGE_EDITOR, PROPERTY_HINT_ENUM, "res://fish-tank/PlantScenes/", ".tscn"))
		properties.append(add_property("stage_ticks %s" % i, TYPE_INT, PROPERTY_USAGE_EDITOR, PROPERTY_HINT_RANGE, "1,50"))
		var dict_enum_string : String = ""
		var dir = "res://fish-tank/NutrientTypes/"
		var files : Array[String] = get_all_files(dir, ".tres")
		for file in files:
			dict_enum_string += file.replace(dir, "").replace(".tres", "") + ","
		properties.append(add_property("nutrient_ranking %s" % i, TYPE_DICTIONARY, PROPERTY_USAGE_EDITOR, PROPERTY_HINT_TYPE_STRING, "%d/%d:%s;%d/%d:0,1,0.05" % [TYPE_STRING, PROPERTY_HINT_ENUM, dict_enum_string, TYPE_FLOAT, PROPERTY_HINT_RANGE]))
		properties.append(add_property("environment_nutrient %s" % i, TYPE_DICTIONARY, PROPERTY_USAGE_EDITOR, PROPERTY_HINT_TYPE_STRING, "%d/%d:%s;%d/%d:0,1,0.05" % [TYPE_STRING, PROPERTY_HINT_ENUM, dict_enum_string, TYPE_FLOAT, PROPERTY_HINT_RANGE]))

	return properties

func _get(property):
	if property.begins_with("plant_model"):
		var index = property.get_slice(" ", 1).to_int()
		if index > plant_stages.size():
			return null
		return plant_stages[index]
	if property.begins_with("nutrient_ranking"):
		var index = property.get_slice(" ", 1).to_int()
		if index > plant_stages.size():
			return null
		return stage_nutrients[index]
	if property.begins_with("environment_nutrient"):
		var index = property.get_slice(" ", 1).to_int()
		if index > plant_stages.size():
			return null
		return environment_nutrient[index]
	if property.begins_with("stage_ticks"):
		var index = property.get_slice(" ", 1).to_int()
		if index > stage_ticks.size():
			return null
		return stage_ticks[index]

func _set(property, value):
	if property.begins_with("plant_model"):
		if value == null || value == "<null>":
			notify_property_list_changed()
			return true

		var index = property.get_slice(" ", 1).to_int()
		plant_stages[index] = value
		print("%s: %s with list at %s " % [property, value, plant_stages.size()])
		notify_property_list_changed()
		return true
	if property.begins_with("nutrient_ranking"):
		var index = property.get_slice(" ", 1).to_int()
		stage_nutrients[index].assign(value)
		print("%s: %s with list at %s " % [property, value, stage_nutrients.size()])
		notify_property_list_changed()
		return true
	if property.begins_with("environment_nutrient"):
		var index = property.get_slice(" ", 1).to_int()
		environment_nutrient[index].assign(value)
		print("%s: %s with list at %s " % [property, value, stage_nutrients.size()])
		notify_property_list_changed()
		return true
	if property.begins_with("stage_ticks"):
		var index = property.get_slice(" ", 1).to_int()
		stage_ticks[index] = value
		print("%s: %s with list at %s " % [property, value, stage_nutrients.size()])
		notify_property_list_changed()
		return true

	return false

func add_property_enum_from_dir(name: String, type: Variant, usage: Variant, hint: Variant, dir : String, ext : String) -> Dictionary:
	var files := get_all_files(dir, ext)
	var s : String = ""
	for f in files:
		s += "%s," % f
	s += "<null>"
	var d = {
		"name" : name,
		"type": type,
		"usage": usage,
		"hint": hint,
		"hint_string": s
	}
	return d

func add_property(name: String, type: Variant, usage: Variant, hint: Variant, hint_string : String) -> Dictionary:
	return {
		"name" : name,
		"type": type,
		"usage": usage,
		"hint": hint,
		"hint_string": hint_string
	}

func add_subgroup(name: String) -> Dictionary:
	return {
		"name" : name,
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_SUBGROUP,
		"hint": PROPERTY_HINT_NONE,
		"hint_string": ""
		}


static func get_all_files(path: String, file_ext := "", files : Array[String] = []) -> Array[String]:
	var dir : = DirAccess.open(path)
	if file_ext.begins_with("."): # get rid of starting dot if we used, for example ".tscn" instead of "tscn"
		file_ext = file_ext.substr(1,file_ext.length()-1)
	
	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin()

		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				# recursion
				files = get_all_files(dir.get_current_dir() +"/"+ file_name, file_ext, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue
				
				files.append(dir.get_current_dir() +"/"+ file_name)

			file_name = dir.get_next()
	else:
		print("[get_all_files()] An error occurred when trying to access %s." % path)
	return files
