extends Node

class_name ProceduralRoomGenerator

const ROOMS_PATH: String = "res://shared/procedural-level/rooms/"

var _rng := RandomNumberGenerator.new()
var min_rooms: int
var max_rooms: int
var _done: bool = false
var _room_counter: int = 1

static func from_seed(seed: String) -> ProceduralRoomGenerator:
	print("seed is: " + seed)
	var converted_seed = hash(seed)
	print("converted to: " + str(converted_seed))
	var prg = ProceduralRoomGenerator.new()
	prg._rng.set_seed(converted_seed)
	return prg

func _ready():
	get_tree().change_scene_to_packed(load(choose_start()))

func _process(delta):
	if _room_counter == 1:
		generate_level()
		print("rooms: " + str(_room_counter))
		_done = _room_counter > 1

func choose_start() -> String:
	var rooms = FileUtil.getFilesAt(ROOMS_PATH).filter(func(r: String): return r.contains("rooms/start_"))
	return rooms[_rng.randi_range(0, rooms.size()-1)]

func generate_level():
	print("generate_level")
	var available_doors = get_remaining_doors()
	while available_doors.size() > 0:
		var door = pick_door(available_doors)
		load_next_map(door, get_any_map(door))
		available_doors = get_remaining_doors()
		_room_counter += 1
		if _room_counter > 999:
			break

func get_any_map(door):
	var all_options = door.map_options.map(func(s): return load(s))
	var viable_options = get_viable_door_map(all_options)
	# there could be none!
	return all_options[_rng.randi_range(0, all_options.size()-1)]

func get_viable_door_map(options: Array) -> Dictionary:
	for option in options:
		var current_room = option.instantiate() as ProceduralRoom
		for room_doors in current_room.get_doors():
			# check if collission would occur if this room would be added at that door
			# use scene.get_overlapping_bodies().is_empty()
			pass
	return {}

func pick_door(doors: Array[Node]) -> ProceduralDoor:
	return doors[_rng.randi_range(0,doors.size()-1)]

func load_next_map(starting_door: ProceduralDoor, map_scene: PackedScene):
	var old_doors = get_remaining_doors()
	var new_map = map_scene.instantiate() as ProceduralRoom
	add_child(new_map)
	var options = get_remaining_doors().filter(func(d): return !old_doors.has(d))
	var target_door = choose(options)
	move_together(starting_door, new_map, target_door)
	starting_door.visible = false
	target_door.visible = false
	# new_map.prepare_room(_rng) # loot and stuff

func get_remaining_doors() -> Array[Node]:
	var doors = get_tree().get_nodes_in_group("door")
	doors = doors.filter(func(d): return d is ProceduralDoor and d.visible)
	return doors

func move_together(parent_door: ProceduralDoor, map_to_move: ProceduralRoom, door_of_map: ProceduralDoor):
	door_of_map.rotate(Vector3(0,1,0), PI)
	map_to_move.global_rotation = difference(parent_door.global_rotation, door_of_map.global_rotation)
	map_to_move.global_position = difference(parent_door.global_position, door_of_map.global_position)

func difference(v1: Vector3, v2: Vector3) -> Vector3:
	return Vector3(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z)

func choose(options: Array) -> ProceduralDoor:
	return options[0] as ProceduralDoor
