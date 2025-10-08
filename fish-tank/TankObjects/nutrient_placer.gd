@tool

extends Node3D
class_name NutrientPlacer

@export var radius : float = 0.3
@export var cylinder : MeshInstance3D
@export var hitbox : Area3D
@export var hitshape : CollisionShape3D
@export var color : Color
@export var light : OmniLight3D

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

signal selected_plants(plants: Array[Plant])

var intersecting_plants : Array[Plant] = []

var velocity : Vector3 = Vector3.ZERO

func _process(delta):
	light.light_color = color
	var cyl : CylinderMesh = cylinder.mesh
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	var sph : SphereShape3D = hitshape.shape
	sph.radius = radius

	cylinder.set_instance_shader_parameter("color", color)

	if Engine.is_editor_hint():
		return
	
	var x = Input.get_axis(left, right)
	var y = Input.get_axis(up, down)
	var input_vector : Vector3 = Vector3(x, 0, y) * delta

	velocity = velocity.lerp(input_vector, 0.1)

	position += velocity
	
	if Input.is_action_just_pressed(accept):
		if intersecting_plants.size() > 0:
			print("accepting plants")
			selected_plants.emit(intersecting_plants)
			queue_free()
		pass
	
	if Input.is_action_just_pressed(cancel):
		queue_free()


func _on_area_3d_area_entered(area: Area3D):
	print("%s as parent of %s" % [area.name, area.get_parent().get_parent().name])
	if area.get_parent().get_parent() is Plant:
		print("%s accepted as plant" % area.get_parent().get_parent().name)
		intersecting_plants.append(area.get_parent().get_parent())


func _on_area_3d_area_exited(area: Area3D):
	print("we're exiting")
	if area.get_parent().get_parent() is Plant:
		intersecting_plants.remove_at(intersecting_plants.find(area.get_parent().get_parent()))

