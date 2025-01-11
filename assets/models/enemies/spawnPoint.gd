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
	return global_position
	#print("== Pos & Scale ==")
	#print(global_position.x)
	#print(scale.x)
	#print(global_position.z)
	#print(scale.z)
	#print("========")
	#var random_x = randf_range(position.x - scale.x, position.x + scale.x)
	#var random_z = randf_range(position.z - scale.z, position.z + scale.z)
	#print("== Randoms ==")
	#print(random_x)
	#print(random_z)
	#print("========")
	#var random_pos_local_space = Vector3(random_x, position.y, random_z)
	#var random_pos_to_global = to_global()
	#var real_global_pos = Vector3.ZERO
	#real_global_pos.x = random_pos_to_global.x + global_position.x
	#real_global_pos.y = random_pos_to_global.y + global_position.y
	#real_global_pos.z = random_pos_to_global.z + global_position.z
	#return real_global_pos
