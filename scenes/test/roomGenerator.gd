extends Node3D

class_name ProceduralRoomGenerator

var _rng := RandomNumberGenerator.new()
var seed: String
var min_rooms: int
var max_rooms: int

func _ready():
	_rng.set_seed(hash(seed))
	# look foor start rooms and pick one
	generate_level()
	# event: loading is done!
	# start ai

func generate_level():
	var available_doors = get_all_doors()
	while available_doors.size() > 0:
		var door = pick_door(available_doors)
		load_next_map(door, door.get_any_map(_rng))
		available_doors = get_all_doors().filter(func(d): return d.visible)

func pick_door(doors: Array[Node]) -> ProceduralDoor:
	return doors[_rng.randi_range(0,doors.size()-1)]

func load_next_map(starting_door: ProceduralDoor, map_scene: PackedScene):
	var old_doors = get_all_doors()
	var new_map = map_scene.instantiate() as Node3D
	add_child(new_map)
	var options = get_all_doors().filter(func(d): return !old_doors.has(d))
	var target_door = choose(options)
	move_together(starting_door, new_map, target_door)
	starting_door.visible = false
	target_door.visible = false
	# new_map.prepare_room(_rng) # loot and stuff

func get_all_doors() -> Array[Node]:
	return get_tree().get_nodes_in_group("door").filter(func(d): return d is ProceduralDoor)

func move_together(parent_door: Node3D, map_to_move: Node3D, door_of_map: Node3D):
	door_of_map.rotate(Vector3(0,1,0), PI)
	map_to_move.global_rotation = difference(parent_door.global_rotation, door_of_map.global_rotation)
	map_to_move.global_position = difference(parent_door.global_position, door_of_map.global_position)

func difference(v1: Vector3, v2: Vector3) -> Vector3:
	return Vector3(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z)

func choose(options: Array):
	return options[0]
