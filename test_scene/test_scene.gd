extends Node3D

@export var tank : Tank 
@export var vbox : VBoxContainer
@export var textbox : TextEdit

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

func _process(_delta):
	read_plant_data()

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

func read_plant_data() -> void:
	var text : String = ""
	var i : int = 0

	
	for plant : Plant in tank.plants:
		var current_stage = plant.get_stage_index(plant.ticks_elapsed, plant.stage_ticks)
		text += "plant %d current stage: %d \n" % [i, current_stage]
		text += "data file: %s \n" % plant.plant_data_file
		text += "quality: %s \n" % plant.quality
		
		text += "nutrient ranking\n"
		for nut in plant.nutrient_ranking[current_stage]:
			text += " -> %s : %f \n" % [nut, plant.nutrient_ranking[current_stage][nut]]

	textbox.text = text
