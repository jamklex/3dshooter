extends Area3D

class_name SpawnPoint

@export var enemies: Array[PackedScene]
@export var limit_spawns: bool = false
@export var max_spawns: int = 5
var spawns_left: int = max_spawns

func can_spawn() -> bool:
	return !limit_spawns or spawns_left > 0

func spawn_enemy(type: Enemy.ENEMY_TYPE) -> Enemy:
	var enemy = enemies.pick_random().instantiate() as Enemy
	get_tree().root.add_child(enemy)
	enemy.global_position = _get_random_position()
	if limit_spawns:
		spawns_left -= 1
	enemy.process_enemy_type_attributes(int(type))
	return enemy

func _get_random_position() -> Vector3:
	var scale_x_range = scale.x / 2
	var scale_z_range = scale.z / 2
	var random_x = randf_range(-scale_x_range, scale_x_range) / scale.x
	var random_z = randf_range(-scale_z_range, scale_z_range) / scale.z
	return to_global(Vector3(random_x, 0, random_z))
