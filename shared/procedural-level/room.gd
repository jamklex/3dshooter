extends Node3D

class_name ProceduralRoom

func get_available_doors() -> Array[ProceduralDoor]:
	return get_doors(self)

func get_doors(parent) -> Array[ProceduralDoor]:
	var doors: Array[ProceduralDoor] = []
	for child in parent.get_children():
		if child is ProceduralDoor:
			doors.push_back(child)
		else:
			doors.append_array(get_doors(child))
	return doors
