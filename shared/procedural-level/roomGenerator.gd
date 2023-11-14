extends Node

class_name ProceduralRoomGenerator

const ROOMS_PATH: String = "res://shared/procedural-level/rooms/"

var _rng := RandomNumberGenerator.new()
var min_rooms: int
var max_rooms: int
var _done: bool = false
var _room_counter: int = 1
const MAX_ROOM_COUNT: int = 25

static func from_seed(seed: String) -> ProceduralRoomGenerator:
	var prg = ProceduralRoomGenerator.new()
	prg._rng.set_seed(hash(seed))
	print("seed loaded: " + str(prg._rng.get_seed()))
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
	var available_doors = get_remaining_doors()
	while available_doors.size() > 0:
		if _room_counter >= MAX_ROOM_COUNT:
			break
		var door = available_doors[_rng.randi_range(0,available_doors.size()-1)]
		load_random_map(door)
		available_doors = get_remaining_doors()

func get_remaining_doors() -> Array[Node]:
	var doors = get_tree().get_nodes_in_group("door")
	doors = doors.filter(func(d): return d is ProceduralDoor and d.visible)
	return doors

func load_random_map(door:ProceduralDoor):
	var options = get_viable_options(door)
	var maps = options.keys()
	if maps.is_empty():
		door.visible = false
		return
	var choosen_map = maps[_rng.randi_range(0,maps.size()-1)] as ProceduralRoom
	var doors = options.get(choosen_map)
	var choosen_door = doors[_rng.randi_range(0,doors.size()-1)] as ProceduralDoor
	add_map(door, choosen_map, choosen_door)
	door.visible = false
	choosen_door.visible = false
	_room_counter += 1

func get_viable_options(starting_door: ProceduralDoor) -> Dictionary:
	var viable_options = {}
	for option in starting_door.map_options:
		var current_room = load(option).instantiate() as ProceduralRoom
		var new_doors = current_room.get_available_doors()
		var viable_doors = []
		var i = 0
		for current_door in new_doors:
			if size_check(starting_door, option, i):
				viable_doors.push_back(current_door)
			i += 1
		if not viable_doors.is_empty():
			viable_options[current_room] = viable_doors
	return viable_options

func size_check(starting_door: ProceduralDoor, room_path: String, door_counter: int) -> bool:
	var current_room = load(room_path).instantiate() as ProceduralRoom
	var door = current_room.get_available_doors()[door_counter]
	add_map(starting_door, current_room, door)
	var result = not starting_door.get_parent_room().collides_with(current_room)
	current_room.free()
	return result

func add_map(parent_door: ProceduralDoor, map_to_move: ProceduralRoom, door_of_map: ProceduralDoor):
	add_child(map_to_move)
	door_of_map.rotate(Vector3(0,1,0), PI)
	map_to_move.global_rotation = difference(parent_door.global_rotation, door_of_map.global_rotation)
	map_to_move.global_position = difference(parent_door.global_position, door_of_map.global_position)

func difference(v1: Vector3, v2: Vector3) -> Vector3:
	return Vector3(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z)
