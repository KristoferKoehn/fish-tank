extends Node3D
class_name Tank

@export_custom(PROPERTY_HINT_INPUT_NAME, "loose_mode")
var left : String = ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "loose_mode")
var right : String = ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "loose_mode")
var up : String = ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "loose_mode")
var down : String = ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "loose_mode")
var accept : String = ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "loose_mode")
var cancel : String = ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "loose_mode")
var rotate_cw : String = ""
@export_custom(PROPERTY_HINT_INPUT_NAME, "loose_mode")
var rotate_ccw : String = ""

@export var money : int = 1000:
	set(value):
		money = value
		money_change.emit()

signal money_change()
signal plant_list_changed()
signal nutrient_placed()

#for moving the plant around in _process
var current_placing : Node3D = null
var velocity : Vector3 = Vector3.ZERO
var rot_velocity : float = 0.0

#tank save variables
var plants : Array[Plant] = []
var ticks_elapsed : int = 0

#not a save variable
var tank_nutrient_environment : Dictionary = {}

func _ready():
	pass

func tick() -> void:
	#we gotta have two loops so we can accumulate the environment before we do the main tick. 

	for plant in plants:
		plant.get_nutrient_environment(tank_nutrient_environment)# <- accumulate environment data


	for plant in plants:		
		plant.tick(tank_nutrient_environment)


func _process(delta):
	if current_placing is Plant && current_placing.is_node_ready():
		var x = Input.get_axis(left, right)
		var y = Input.get_axis(up, down)
		var r = Input.get_axis(rotate_cw, rotate_ccw) * delta
		var input_vector : Vector3 = Vector3(x, 0, y) * delta

		rot_velocity = lerp(rot_velocity, r, 0.1)
		velocity = velocity.lerp(input_vector, 0.1)

		current_placing.position += velocity
		current_placing.rotate_y(rot_velocity)
		
		if Input.is_action_just_pressed(accept) && current_placing.valid_placement:
			plants.append(current_placing)
			plant_list_changed.emit()
			current_placing.placing_mode(false)
			current_placing = null
		
		if Input.is_action_just_pressed(cancel):
			current_placing.queue_free()

	
func place_plant(data : PlantData) -> void:
	var p : Plant = Plant.new()
	p.initialize_plant(data)
	add_child(p)
	p.placing_mode(true)
	p.attach_collision_notify()
	current_placing = p

func load_data(save_location : String) -> void:
	if !ResourceLoader.exists(save_location):
		return

	var save : TankSave = ResourceLoader.load(save_location)
	for plant_save in save.current_plants:
		var p : Plant = Plant.new()
		p.load_from_save_data(plant_save)
		add_child(p)
		plants.append(p)

	plant_list_changed.emit()
	money = save.money
	ticks_elapsed = save.total_ticks
	#tank_nutrient_environment = save.ambient_nutrients <- this doesn't need to be saved because it's calculated before each tick

func save_data(save_location : String) -> void:
	var save : TankSave = TankSave.new()
	for plant : Plant in plants:
		save.current_plants.append(plant.get_save_data())

	save.money = money
	save.total_ticks = ticks_elapsed
	ResourceSaver.save(save, save_location)

func get_ui() -> Control:
	var ui = preload("res://fish-tank/tank/tank_ui.tscn").instantiate()
	ui.tank = self
	return ui

func start_nutrient_placer(key: String, color : Color) -> void:
	var n : NutrientPlacer = load("res://fish-tank/TankObjects/nutrient_placer.tscn").instantiate()
	n.color = color
	add_child(n)
	current_placing = n
	n.tree_exiting.connect(func():
		current_placing = null
	)

	n.selected_plants.connect(func(selected_plants : Array[Plant]):
		for plant in selected_plants:
			plant.applied_nutrients[key] = plant.applied_nutrients.get(key, 0.0) + 1.0
		nutrient_placed.emit()
	)

	n.left = left
	n.right = right
	n.up = up
	n.down = down
	n.accept = accept
	n.cancel = cancel


