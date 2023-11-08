extends Node3D

class_name ProceduralDoor

@export var map_options: Array[PackedScene]

func get_any_map(seed) -> PackedScene:
	# use seed
	return map_options.pick_random()
