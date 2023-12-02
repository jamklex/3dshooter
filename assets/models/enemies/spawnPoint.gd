extends Area3D

class_name SpawnPoint

@export var enemies: Array[String]
@export var limit_spawns: bool = false
@export var max_spawns: int = 5
var spawns_left: int = max_spawns

func can_spawn() -> bool:
	return !limit_spawns or spawns_left >= 0

func spawn_random():
	var enemy = load(enemies.pick_random()).instantiate()
	add_child(enemy)
	print("enemy spawned")
	if limit_spawns:
		spawns_left -= 1
