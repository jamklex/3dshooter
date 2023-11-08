extends Node3D

class_name ProceduralDoor

@export var map_options: Array[PackedScene]

func get_any_map(rng: RandomNumberGenerator) -> PackedScene:
	return map_options[rng.randi_range(0, map_options.size()-1)]
