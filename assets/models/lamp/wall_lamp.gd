extends Node3D

@export var color = "c05239" as Color
@onready var lamp = $lamp as CSGBox3D
@onready var light = $lamp/light as SpotLight3D

func _ready():
	var lamp_material = lamp.material as StandardMaterial3D
	lamp_material.albedo_color = color
	lamp_material.emission = color
	light.light_color = color
