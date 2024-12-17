extends Area3D

class_name SpawnPoint

@export var enemies: Array[PackedScene]
@export var limit_spawns: bool = false
@export var max_spawns: int = 5
var spawns_left: int = max_spawns

func can_spawn() -> bool:
	return !limit_spawns or spawns_left > 0

func spawn_random() -> Enemy:
	var enemy = enemies.pick_random().instantiate() as Enemy
	get_tree().root.add_child(enemy)
	enemy.global_position = _get_random_position()
	if limit_spawns:
		spawns_left -= 1
	return enemy

func _get_random_position() -> Vector3:
	var random_x = randf_range(global_position.x - scale.x, global_position.x + scale.x)
	var random_z = randf_range(global_position.z - scale.z, global_position.z + scale.z)
	return Vector3(random_x, global_position.y, random_z)
