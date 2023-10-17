extends StaticBody3D
class_name Dummy

@export_file var respawn_scene_path
@export var respawnTime:int

var _spawnTimer:Timer

func _ready():
	_spawnTimer = Timer.new()
	_spawnTimer.timeout.connect(_respawn)
	add_child(_spawnTimer)

func _respawn():
	var packedScene = load(respawn_scene_path) as PackedScene
	if not packedScene:
		return
	var newDummy = packedScene.instantiate() as Dummy
	WorldUtil.add_child(newDummy)
	newDummy.global_position = global_position
	newDummy.global_rotation = global_rotation
	queue_free()

func hideAndStartRespawnTimer():
	if not visible:
		return
	visible = false
	_spawnTimer.start(respawnTime)
