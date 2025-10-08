extends Node3D
class_name Plant

var placing : bool = false
var valid_placement : bool = true

var invalid_placement_material : Material = preload("res://fish-tank/assets/materials/invalid_placement.tres")
var valid_placement_material : Material = preload("res://fish-tank/assets/materials/valid_placement.tres")
var plant_material : Material = preload("res://fish-tank/assets/materials/plant_material.tres")

#plant save variables. These are put in the save file
var ticks_elapsed : int = 0
var plant_data_file : String = ""
var quality : float = 0
var applied_nutrients : Dictionary[String, float] = {}
#includes position
#includes rotation

#Plant resource variables, these are shared across all plants of this type
#pull these in from the plant_data resource
var stage_scenes : Array[PackedScene] = []
var nutrient_ranking : Array[Dictionary] = []
var stage_ticks : Array[int] = []
var environment_nutrient : Array[Dictionary] = []

var current_stage : Node3D

func tick(nutrient_environment: Dictionary) -> void:
	var nutrients_total : Dictionary = {}
	nutrients_total.merge(nutrient_environment)
	nutrients_total.merge(applied_nutrients)
	for key in nutrients_total.keys():
		if nutrient_ranking[get_stage_index(ticks_elapsed, stage_ticks)].has(key):
			quality += nutrient_ranking[get_stage_index(ticks_elapsed, stage_ticks)][key] * nutrients_total[key] 
	#should meet previous reqs before increasing. otherwise, if reqs change between stages you'll have no way to react. gotta be cozy!

	#now we actually increase the tick and make the changes
	var prev_stage = get_stage_index(ticks_elapsed, stage_ticks)
	ticks_elapsed += 1
	if get_stage_index(ticks_elapsed, stage_ticks) > prev_stage:
		set_plant_stage(stage_scenes[get_stage_index(ticks_elapsed, stage_ticks)].instantiate())
	
func get_nutrient_environment(nutrient_environment: Dictionary) -> Dictionary:
	var n_dict: Dictionary = environment_nutrient[get_stage_index(ticks_elapsed, stage_ticks)]
	for n_key in n_dict.keys():
		var value: float = n_dict[n_key]
		nutrient_environment[n_key] = nutrient_environment.get(n_key, 0.0) + value
	return nutrient_environment

func get_save_data() -> PlantSave:
	var save : PlantSave = PlantSave.new()
	save.ticks_elapsed = ticks_elapsed
	save.plant_data_file = plant_data_file
	save.quality = quality
	save.position = position
	save.rotation = rotation
	save.applied_nutrients = applied_nutrients
	return save

func load_from_save_data(save : PlantSave) -> void:
	plant_data_file = save.plant_data_file
	initialize_plant(ResourceLoader.load(plant_data_file))
	ticks_elapsed = save.ticks_elapsed
	quality = save.quality
	position = save.position
	rotation = save.rotation
	applied_nutrients = save.applied_nutrients
	set_plant_stage(stage_scenes[get_stage_index(ticks_elapsed, stage_ticks)].instantiate())

func initialize_plant(plant_data: PlantData) -> void:
	for s in plant_data.plant_stages:
		stage_scenes.append(ResourceLoader.load(s, "", ResourceLoader.CACHE_MODE_IGNORE_DEEP))

	nutrient_ranking = plant_data.stage_nutrients
	plant_data_file = plant_data.resource_path
	environment_nutrient = plant_data.environment_nutrient
	stage_ticks = plant_data.stage_ticks
	set_plant_stage(stage_scenes[get_stage_index(ticks_elapsed, stage_ticks)].instantiate())
	
func get_stage_index(_ticks_elapsed: int, _stage_ticks: Array[int]) -> int:
	var total := 0
	for i in range(_stage_ticks.size()):
		total += stage_ticks[i]
		if _ticks_elapsed < total:
			return i
	return stage_ticks.size() - 1

func get_descendants_of_type(parent: Node, node_type) -> Array:
	var matches: Array = []
	for child in parent.get_children():
		if is_instance_of(child, node_type):
			matches.append(child)
		matches += get_descendants_of_type(child, node_type)
	return matches

func attach_collision_notify():
	var scene_areas : Array = get_descendants_of_type(self, Area3D)
	for area : Area3D in scene_areas:
		area.area_entered.connect(func(_x): 
			if !placing:
				return
			assign_material(invalid_placement_material)
			valid_placement = false
		)
		area.area_exited.connect(func(_x): 
			if !placing:
				return
			if area.get_overlapping_areas().size() == 0:
				valid_placement = true
				assign_material(valid_placement_material)
		)

func assign_material(mat : Material):
	var plant_meshes : Array = get_descendants_of_type(self, MeshInstance3D)
	for m : MeshInstance3D in plant_meshes:
		m.mesh.surface_set_material(0, mat)

func set_plant_stage(stage : Node3D):
	if current_stage:
		current_stage.queue_free()
	current_stage = stage
	add_child(current_stage)

func placing_mode(flag : bool) -> void:
	placing = flag
	if flag:
		set_plant_stage(stage_scenes[stage_scenes.size()-1].instantiate())
		assign_material(valid_placement_material)
	else:
		set_plant_stage(stage_scenes[0].instantiate())
		assign_material(plant_material)
