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

#for moving the plant around in _process
var current_placing : Plant = null
var velocity : Vector3 = Vector3.ZERO
var rot_velocity : float = 0.0

#tank save variables
var plants : Array[Plant] = []
var ticks_elapsed : int = 0
var tank_nutrient_environment : Dictionary = {}

func _ready():
	pass

func _tick() -> void:
	#we gotta have two loops so we can accumulate the environment before we do the main tick. 

	for plant in plants:
		#plant.get_nutrient_environment(tank_nutrient_environment) <- accumulate environment data
		pass

	for plant in plants:		
		#plant.tick(tank_nutrient_environment) <- tick with environment
		pass

func place_plant(data : PlantData) -> void:
		var p : Plant = Plant.new()
		p.initialize_plant(data)
		add_child(p)
		current_placing = p

func _process(delta):
	if current_placing:
		var x = Input.get_axis(left, right)
		var y = Input.get_axis(up, down)
		var r = Input.get_axis(rotate_cw, rotate_ccw) * delta
		var input_vector : Vector3 = Vector3(x, 0, y) * delta

		rot_velocity = lerp(rot_velocity, r, 0.1)
		velocity = velocity.lerp(input_vector, 0.1)

		current_placing.position += velocity
		current_placing.rotate_y(rot_velocity)
		var mat : StandardMaterial3D = current_placing.mesh.surface_get_material(0)
		mat.stencil_mode = BaseMaterial3D.STENCIL_MODE_OUTLINE
		mat.stencil_color = Color.YELLOW_GREEN

		if Input.is_action_just_pressed(accept):
			plants.append(current_placing)
			mat.stencil_mode = BaseMaterial3D.STENCIL_MODE_DISABLED
			mat.next_pass = null
			current_placing = null
		
		if Input.is_action_just_pressed(cancel):
			current_placing.queue_free()
