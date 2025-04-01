extends Node3D
class_name FloatingHealthBar

@onready var _meshInstance: MeshInstance3D = $MeshInstance3D
@onready var _progressBar: ProgressBar = $SubViewport/health
var _health: int = 0
var _maxHealth: int = 0
var _last_cam_pos: Vector3
var _current_cam_pos: Vector3

func setMaxHealth(newMaxHealth: int):
	_maxHealth = newMaxHealth
	
func setHealth(newHealth: int):
	_health = newHealth
	_refresh()
	
func _refresh():
	if _health == _maxHealth:
		_meshInstance.visible = false
		return
	_meshInstance.visible = true
	_progressBar.value = _health
	_progressBar.max_value = _maxHealth

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not WorldUtil.player_cam:
		return
	_current_cam_pos = WorldUtil.player_cam.global_position
	if _current_cam_pos == _last_cam_pos:
		return
	_last_cam_pos = _current_cam_pos
	_meshInstance.look_at(_current_cam_pos, Vector3.UP, true)
