extends Node3D

@export var tank : Tank 
@export var vbox : VBoxContainer
@export var textbox : TextEdit

func _ready():
	add_child(tank.get_ui())
