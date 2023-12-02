extends Node

class_name ProceduralRoomGenerator

const ROOMS_PATH: String = "res://shared/procedural-level/rooms/"

var _rng := RandomNumberGenerator.new()
var min_rooms: int
var max_rooms: int
var _done: bool = false
var _room_counter: int = 0
const MAX_ROOM_COUNT: int = 25
var _total_enemies: int = 0
var _max_enemies: int = 0
var _initial_enemies: int = 0

static func from_seed(_seed: String) -> ProceduralRoomGenerator:
	print("ProceduralRoomGenerator with seed: " + _seed)
	var prg = ProceduralRoomGenerator.new()
	prg._rng.set_seed(hash(_seed))
	print("internal seed: " + str(prg._rng.get_seed()))
	return prg

func _ready():
	get_tree().change_scene_to_packed(load(choose_start()))
	_room_counter += 1

func set_max_enemies(amount: int):
	_max_enemies = amount

func set_initial_enemies(amount: int):
	_initial_enemies = amount

func _process(_delta):
	if _room_counter <= 1:
		generate_level()
		print("rooms: " + str(_room_counter))
		if _room_counter > 1:
			spawn_enemies(_initial_enemies)
			set_generated(true)

func spawn_enemies(amount):
	if amount <= 0 or _total_enemies >= _max_enemies:
		return
	var spawns = get_tree().get_nodes_in_group("spawns")
	for i in amount:
		var point = spawns.filter(func(s): return s is SpawnPoint and s.can_spawn()).pick_random() as SpawnPoint
		if point == null:
			return
		point.spawn_random()
		_total_enemies += 1
		if _total_enemies >= _max_enemies:
			break

func is_generated() -> bool:
	return _done

func set_generated(value: bool):
	_done = value

func next_loot_visible() -> bool:
	return _rng.randf() <= 0.65

func choose_start() -> String:
	var room_paths = FileUtil.getFilesAt(ROOMS_PATH)
	var room_instances = room_paths.map(func(s: String): return load(s).instantiate() as ProceduralRoom)
	var starting_rooms = room_instances.filter(func(p: ProceduralRoom): return p is ProceduralStartRoom)
	return random_of(starting_rooms).scene_file_path

func generate_level():
	var available_doors = get_remaining_doors()
	while available_doors.size() > 0:
		if _room_counter >= MAX_ROOM_COUNT:
			break
		var door = random_of(available_doors)
		load_random_map(door)
		available_doors = get_remaining_doors()

func get_remaining_doors() -> Array[Node]:
	var doors = get_tree().get_nodes_in_group("door")
	doors = doors.filter(func(d): return d is ProceduralDoor and d.visible)
	return doors

func load_random_map(door:ProceduralDoor):
	var maps = door.get_possible_rooms()
	if maps.is_empty():
		door.visible = false
		return
	var choosen_map = random_of(maps) as ProceduralRoom
	var doors = choosen_map.get_available_doors()
	var choosen_door = random_of(doors) as ProceduralDoor
	add_map(door, choosen_map, choosen_door)
	door.visible = false
	choosen_door.visible = false
	_room_counter += 1

func add_map(parent_door: ProceduralDoor, map_to_move: ProceduralRoom, door_of_map: ProceduralDoor):
	add_child(map_to_move)
	door_of_map.rotate(Vector3(0,1,0), PI)
	map_to_move.global_rotation = difference(parent_door.global_rotation, door_of_map.global_rotation)
	map_to_move.global_position = difference(parent_door.global_position, door_of_map.global_position)

func difference(v1: Vector3, v2: Vector3) -> Vector3:
	return Vector3(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z)

func random_of(array: Array):
	return array[_rng.randi_range(0, array.size()-1)]
