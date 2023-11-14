extends Node3D

class_name ProceduralDoor

@export var map_options: Array[String]

func get_parent_room() -> ProceduralRoom:
	var parent = get_parent()
	while not parent is ProceduralRoom:
		parent = parent.get_parent()
	return parent
