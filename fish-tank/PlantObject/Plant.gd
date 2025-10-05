extends MeshInstance3D
class_name Plant

@export var placing : bool = false



#plant save variables. These are put in the save file
var ticks_elapsed : int = 0
var plant_data_file : String = ""
var quality : float = 0
var applied_nutrients : Dictionary[String, float] = {}
#includes position
#includes rotation

#Plant resource variables, these are shared across all plants of this type
#pull these in from the plant_data resource
var meshes : Array[ArrayMesh] = []
var nutrient_ranking : Array[Dictionary] = []
var stage_ticks : Array[int] = []
var environment_nutrient : Array[Dictionary] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector3(0.25,0.25, 0.25)
	pass # Replace with function body.

func tick(nutrient_environment: Dictionary) -> void:
	var nutrients_total : Dictionary[String, float] = {}
	nutrients_total.merge(nutrient_environment)
	nutrients_total.merge(applied_nutrients)
	for key in nutrients_total:
		if nutrient_ranking.has(key):
			quality += nutrient_ranking[get_stage_index(ticks_elapsed, stage_ticks)][key] * nutrients_total[key] 
	#should meet previous reqs before increasing. otherwise, if reqs change between stages you'll have no way to react. gotta be cozy!

	#now we actually increase the tick and make the changes
	ticks_elapsed += 1
	mesh = meshes[get_stage_index(ticks_elapsed, stage_ticks)]
	

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
	mesh = meshes[get_stage_index(ticks_elapsed, stage_ticks)]

func initialize_plant(plant_data: PlantData) -> void:
	for s in plant_data.plant_stages:
		meshes.append(ResourceLoader.load(s, "", ResourceLoader.CACHE_MODE_IGNORE_DEEP))
	nutrient_ranking = plant_data.stage_nutrients
	environment_nutrient = plant_data.environment_nutrient
	stage_ticks = plant_data.stage_ticks
	mesh = meshes[0]
	var res = ResourceLoader.load("res://fish-tank/assets/materials/plant_material.tres","", ResourceLoader.CACHE_MODE_IGNORE).duplicate(true)
	mesh.surface_set_material(0, res)
	#set_surface_override_material(0,res)

func get_stage_index(_ticks_elapsed: int, _stage_ticks: Array[int]) -> int:
	var total := 0
	for i in range(_stage_ticks.size()):
		total += stage_ticks[i]
		if _ticks_elapsed < total:
			return i
	return stage_ticks.size() - 1