extends Node

class_name ProceduralRoomGenerator

const ROOMS_PATH: String = "res://shared/procedural-level/rooms/starts/"
const SPAWN_USAGE_MIN: int = 3

var _rng := RandomNumberGenerator.new()
var min_rooms: int
var max_rooms: int
var _done: bool = false
var _generated: bool = false
var _room_counter: int = 0
const MAX_ROOM_COUNT: int = 25
var _enemies: Dictionary = {}
var _additional_items: Dictionary = {}
var _next_spawn_time:float = 0
var audioPlayer: AudioStreamPlayer3D = AudioStreamPlayer3D.new()

static func from_seed(_seed: String) -> ProceduralRoomGenerator:
	var prg = ProceduralRoomGenerator.new()
	prg._rng.set_seed(hash(_seed))
	return prg

func _ready():
	get_tree().change_scene_to_file(choose_start())
	_room_counter += 1
	
func set_enemies(enemyDict:Dictionary):
	_enemies.clear()
	for key in enemyDict.keys():
		_enemies[int(key)] = enemyDict[key]

func set_additional_items(itemDict: Dictionary):
	_additional_items = itemDict

func _process(_delta):
	if !_generated:
		await generate_level()
		return
	if !_done:
		if _room_counter > 1:
			if !spawn_pickable_items(_additional_items):
				set_container_items(_additional_items)
			_done = true
			add_child(audioPlayer)
			audioPlayer.bus = "Sound"
			audioPlayer.set_max_db(-10)
			SoundUtil.playAtConstantPitch(audioPlayer, SoundUtil.SoundName.ROUND_START)
		return
	if len(_enemies.keys()) == 0:
		return
	spawn_enemies()

func _get_rest_num_of_enemies():
	var num_of_enemies = 0
	for enemy_type in _enemies:
		num_of_enemies += _enemies[enemy_type]
	return num_of_enemies

func spawn_enemies():
	if len(_enemies.keys()) == 0:
		return
	if Time.get_unix_time_from_system() < _next_spawn_time:
		return
	var nextEnemy = _enemies.keys().pick_random()
	var amount = 1
	_enemies[nextEnemy] -= amount
	if _enemies[nextEnemy] <= 0:
		_enemies.erase(nextEnemy)
	var spawns = get_tree().get_nodes_in_group("spawns").filter(func(s): return s is SpawnPoint)
	for i in range(amount):
		var availableSpawns = spawns.filter(func(s): return s.can_spawn())
		availableSpawns.sort_custom(func(a,b): return _distanceToPlayer(a) > _distanceToPlayer(b))
		var spawn_size = min(max(availableSpawns.size()/2, SPAWN_USAGE_MIN), availableSpawns.size())
		availableSpawns.resize(min(spawn_size, availableSpawns.size()))
		var point = availableSpawns.pick_random() as SpawnPoint
		if point == null:
			return
		var enemy = point.spawn_enemy(nextEnemy)
		if len(_enemies.keys()) == 0:
			break
	_next_spawn_time = Time.get_unix_time_from_system() + _rng.randi_range(5, 10)

func _distanceToPlayer(node: Node3D) -> float:
	var offset = WorldUtil.player.body.get_global_position() - node.get_global_position()
	var distance = abs(offset.x) + abs(offset.y) + abs(offset.z)
	return distance

func spawn_pickable_items(itemDict: Dictionary) -> bool:
	var items = get_tree().get_nodes_in_group("items").filter(func(i): return i is Pickable)
	if items.is_empty():
		return false
	for item in items:
		item.setVisible(false)
	for item in itemDict.keys():
		var amount = itemDict[item]
		var foundItems = items.filter(func(i: Pickable): return i.item_id == item)
		for n in range(amount):
			if !foundItems or foundItems.is_empty():
				break
			var foundItem = foundItems.pop_at(_rng.randi_range(0, foundItems.size()-1))
			foundItem.setVisible(true)
			itemDict[item] -= 1
	var invisible_items = items.filter(func(i): return !i.visible)
	for item in invisible_items:
		item.queue_free()
	return true

func set_container_items(itemDict: Dictionary):
	var lootables = get_tree().get_nodes_in_group("lootable") as Array[Lootable]
	var num_of_items = len(itemDict)
	var item_ids = itemDict.keys()
	for index in range(num_of_items):
		if index >= len(lootables):
			print("More items than lootables")
			return
		var lootable = lootables[index]
		var item_id = item_ids[index]
		var amount = itemDict[item_id]
		lootable.setDropItem(DropItem.create_fix(item_id, amount))

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
		var door = random_of(available_doors)
		load_random_map(door)
		available_doors = get_remaining_doors()
		_room_counter += 1
	_generated = _room_counter > 1

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

func add_map(parent_door: ProceduralDoor, map_to_move: ProceduralRoom, door_of_map: ProceduralDoor):
	get_tree().current_scene.add_child(map_to_move)
	door_of_map.rotate(Vector3(0,1,0), PI)
	map_to_move.global_rotation = difference(parent_door.global_rotation, door_of_map.global_rotation)
	map_to_move.global_position = difference(parent_door.global_position, door_of_map.global_position)

func difference(v1: Vector3, v2: Vector3) -> Vector3:
	return Vector3(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z)

func random_of(array: Array):
	return array[_rng.randi_range(0, array.size()-1)]
