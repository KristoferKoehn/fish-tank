extends Control

@export var tank : Tank 
@export var plant_store : VBoxContainer
@export var widget_store : VBoxContainer
@export var nutrient_store : VBoxContainer
@export var plant_list : VBoxContainer
@export var textbox : TextEdit
@export var money_label : Label

func _ready():
	tank.plant_list_changed.connect(_plant_list_changed)

	var dir : String = "res://fish-tank/PlantTypes/"
	var plant_res : Array[String] = list_files(dir, ".tres")
	for plant : String in plant_res:
		var data : PlantData = ResourceLoader.load(plant)
		var button_label : String = plant.replace(dir, "").replace(".tres", "") # clean it up so the buttons are less ass
		
		var menu_item : HBoxContainer = get_list_button(button_label, str(data.price), Callable(func(): 
			if tank.money > data.price && !tank.current_placing:
				tank.money -= data.price
				tank.place_plant(load(plant))
			else:
				pass
		))

		if plant.contains("widget_"):
			widget_store.add_child(menu_item)
		else:
			plant_store.add_child(menu_item)

	var nut_dir : String = "res://fish-tank/NutrientTypes/"
	var nutrient_res : Array[String] = list_files(nut_dir, ".tres")

	for nutrient in nutrient_res:
		if nutrient.contains("env_"):
			continue
		var data : NutrientPaste = load(nutrient)
		var button_name : String = nutrient.replace(nut_dir, "").replace(".tres", "")
		var menu_item :HBoxContainer = get_list_button(button_name, str(data.price), Callable(func():
			if tank.money > data.price && !tank.current_placing:
				#tank.money -= data.price
				print("DOING THE FUCKING %s PASTE" % button_name)
				tank.start_nutrient_placer(button_name, data.color)

				var a = func():
					print("we're getting the money")
					tank.money -= data.price

				tank.nutrient_placed.connect(a,CONNECT_ONE_SHOT)

			else:
				pass
		))

		nutrient_store.add_child(menu_item)

	money_label.text = "$$" + str(tank.money)

	tank.money_change.connect(func():
		money_label.text = "$$" + str(tank.money)
	)


func _process(_delta):
	read_plant_data()

func get_list_button(button_label : String, cost_label : String, button_effect : Callable) -> Control:
	var hbox : HBoxContainer = HBoxContainer.new()
	var b : Button = Button.new()
	b.text = button_label
	b.pressed.connect(button_effect)
	b.pressed.connect(func(): b.focus_mode = Control.FOCUS_NONE)
	var l : Label = Label.new()
	l.text = cost_label
	var c : Control = Control.new()
	hbox.add_child(b)
	hbox.add_child(c)
	hbox.add_child(l)
	c.size_flags_horizontal = Control.SIZE_EXPAND
	return hbox

func list_files(base_path: String, extension: String) -> Array[String]:
	var results: Array[String] = []
	_traverse_directory(base_path, extension.to_lower(), results)
	return results


func _traverse_directory(path: String, extension: String, results: Array) -> void:
	var items = ResourceLoader.list_directory(path)
	for item in items:
		
		var full_path = path.path_join(item)
		
		if ResourceLoader.exists(full_path):
			
			if full_path.contains(extension):
				print(full_path)
				results.append(full_path)
		else:
			_traverse_directory(full_path, extension, results)


func _on_tick_button_pressed():
	tank.tick()
	$Panel3/MarginContainer/HBoxContainer/TickButton.focus_mode = Control.FOCUS_NONE

func _on_load_button_pressed():
	tank.load_data("user://test.tres")
	$Panel3/MarginContainer/HBoxContainer/LoadButton.focus_mode = Control.FOCUS_NONE

func _on_save_button_pressed():
	tank.save_data("user://test.tres")
	$Panel3/MarginContainer/HBoxContainer/SaveButton.focus_mode = Control.FOCUS_NONE

func _on_delete_button_pressed():
	$Panel3/MarginContainer/HBoxContainer/DeleteButton.focus_mode = Control.FOCUS_NONE
	var dir : DirAccess = DirAccess.open("user://")
	dir.remove("test.tres")

func _plant_list_changed()-> void:
	for n in plant_list.get_children():
		n.queue_free()

	for plant : Plant in tank.plants:
		var b = get_list_button(plant.name,"",Callable(func():

			#ask the are you sure here or whatever

			tank.plants.remove_at(tank.plants.find(plant))
			plant.queue_free()
			tank.plant_list_changed.emit()
		))
		plant_list.add_child(b)

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

		text += "env nutrient\n"
		for nut in plant.environment_nutrient[current_stage]:
			text += " -> %s : %f \n" % [nut, plant.environment_nutrient[current_stage][nut]]

		text += "applied nutrient\n"
		for nut in plant.applied_nutrients:
			text += " -> %s : %f \n" % [nut, plant.applied_nutrients[nut]]

		text += "\n"
		i += 1
	textbox.text = text
