@tool
class_name Minimap extends MarginContainer

@export var target: Node3D
@onready var _camera: Camera3D = $PanelContainer/ViewportContainer/Viewport/MapCam
var offset: Vector3

func _ready() -> void:
	if target == null:
		printerr("No target for minimap assigned!")
		return
	offset = Vector3(0, _camera.global_position.y, 0)

func _process(delta: float) -> void:
	if _camera == null:
		return
	if target == null:
		printerr("No target for minimap assigned!")
		return
	_camera.global_position = target.global_position + offset
