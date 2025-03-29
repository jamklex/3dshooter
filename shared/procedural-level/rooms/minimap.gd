@tool
class_name Minimap extends MarginContainer

@export var target: Node3D
@onready var _camera: Camera3D = $PanelContainer/ViewportContainer/Viewport/MapCam
var _position_offset: Vector3
var _rotation_offset: Vector3

func _ready() -> void:
	if target == null:
		printerr("No target for minimap assigned!")
		return
	_position_offset = Vector3(0, _camera.global_position.y, 0)
	_rotation_offset = Vector3(_camera.global_rotation.x, 0, 0)

func _process(delta: float) -> void:
	if _camera == null:
		return
	if target == null:
		printerr("No target for minimap assigned!")
		return
	_camera.global_position = target.global_position + _position_offset
	var player_rotation = WorldUtil.player_cam.global_rotation
	_camera.global_rotation = Vector3(0,player_rotation.y,player_rotation.z)  + _rotation_offset
