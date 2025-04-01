extends StaticBody3D
class_name Dummy

@export_file var respawn_scene_path
@export var respawnTime:int

var _spawnTimer:Timer
@onready var _shootable:Shootable = $shootable
@onready var _floatingHealthBar: FloatingHealthBar = $FloatingHealthBar

func _ready():
	if _spawnTimer:
		return
	_spawnTimer = Timer.new()
	_spawnTimer.one_shot = true
	_spawnTimer.timeout.connect(_respawn)
	add_child(_spawnTimer)
	
func _refreshHealthBar():
	_floatingHealthBar.setMaxHealth(_shootable.max_health)
	_floatingHealthBar.setHealth(_shootable.health)

func _respawn():
	visible = true
	_shootable.resetHealth()
	_refreshHealthBar()

func hideAndStartRespawnTimer():
	if not visible:
		return
	visible = false
	_spawnTimer.start(respawnTime)
	
func _on_shootable_on_health_changed(health: int) -> void:
	_refreshHealthBar()
	if health <= 0:
		hideAndStartRespawnTimer()
