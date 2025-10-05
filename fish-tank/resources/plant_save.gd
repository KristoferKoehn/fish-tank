extends Resource
class_name PlantSave

@export var ticks_elapsed := 0
@export var plant_data_file : String
@export var quality : float = 0
@export var position : Vector3 
@export var rotation : Vector3
@export var applied_nutrients : Dictionary[String,float]