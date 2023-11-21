extends Node3D

class_name ProceduralDoor

@export var map_options: Array[String]

func get_parent_room() -> ProceduralRoom:
	var parent = get_parent()
	while not parent is ProceduralRoom:
		parent = parent.get_parent()
	return parent

func get_possible_rooms() -> Array[ProceduralRoom]:
	var maps: Array[ProceduralRoom] = []
	for map in map_options:
		maps.push_back(load(map).instantiate() as ProceduralRoom)
	return maps
