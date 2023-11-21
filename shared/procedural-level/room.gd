extends Node3D

class_name ProceduralRoom

func get_available_doors() -> Array[ProceduralDoor]:
	var doors: Array[ProceduralDoor] = []
	for child in get_children():
		if child is ProceduralDoor:
			doors.push_back(child)
	return doors
