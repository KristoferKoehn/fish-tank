extends MeshInstance3D
class_name Plant

@export var placing : bool = false



#plant save variables. These are put in the save file
var ticks_elapsed := 0
var plant_data_file : String
var quality : float = 0
#includes position
#includes rotation

#Plant resource variables, these are shared across all plants of this type
#pull these in from the plant_data resource
var meshes : Array[ArrayMesh] = []
var nutrient_ranking : Array[Dictionary] = []
var stage_ticks : Array[int] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector3(0.25,0.25, 0.25)
	pass # Replace with function body.

func get_save_data() -> PlantSave:
	var save : PlantSave = PlantSave.new()
	save.ticks_elapsed = ticks_elapsed
	save.plant_data_file = plant_data_file
	save.quality = quality
	save.position = position
	save.rotation = rotation
	return save

func load_from_save_data(save : PlantSave) -> void:
	plant_data_file = save.plant_data_file # run initialization after this step
	initialize_plant(ResourceLoader.load(plant_data_file))
	ticks_elapsed = save.ticks_elapsed
	quality = save.quality
	position = save.position
	rotation = save.rotation
	mesh = meshes[get_stage_index(ticks_elapsed, stage_ticks)]


func initialize_plant(plant_data: PlantData) -> void:
	for s in plant_data.plant_stages:
		meshes.append(ResourceLoader.load(s, "", ResourceLoader.CACHE_MODE_IGNORE_DEEP))
	nutrient_ranking = plant_data.stage_nutrients
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
