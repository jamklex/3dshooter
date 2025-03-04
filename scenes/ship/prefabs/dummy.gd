extends StaticBody3D
class_name Dummy

@export_file var respawn_scene_path
@export var respawnTime:int

var _spawnTimer:Timer
@onready var _shootable:Shootable = $shootable

func _ready():
	if _spawnTimer:
		return
	_spawnTimer = Timer.new()
	_spawnTimer.one_shot = true
	_spawnTimer.timeout.connect(_respawn)
	add_child(_spawnTimer)

func _respawn():
	SoundUtil.getSound(SoundUtil.SoundName.LOOT_PICKUP)
	SoundUtil.getSound(SoundUtil.SoundName.AMBIENT_HOME)
	visible = true
	_shootable.resetHealth()

func hideAndStartRespawnTimer():
	if not visible:
		return
	visible = false
	_spawnTimer.start(respawnTime)

func _on_shootable_on_health_changed(health: int) -> void:
	if health <= 0:
		hideAndStartRespawnTimer()
