extends Node3D

@export
var tank : Tank 
@export
var vbox : VBoxContainer


func _ready():
	var dir : String = "res://fish-tank/PlantTypes/"
	var plant_res : Array[String] = get_all_files(dir, ".tres")
	for plant in plant_res:
		var b : Button = Button.new()
		b.text = plant.replace(dir, "").replace(".tres", "") # clean it up so the buttons are less ass
		b.pressed.connect(func(): 
			tank.place_plant(ResourceLoader.load(plant))
			b.focus_mode = Control.FOCUS_NONE
		)
		vbox.add_child(b)


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
