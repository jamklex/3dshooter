@tool
class_name Minimap extends MarginContainer

@export var target: Node3D
@onready var _camera: Camera3D = $PanelContainer/ViewportContainer/Viewport/MapCam
var offset

func _ready() -> void:
	if target == null:
		printerr("No target for minimap assigned!")
		return
	offset = _camera.global_position - target.global_position

func _process(delta: float) -> void:
	if _camera == null:
		return
	if target == null:
		printerr("No target for minimap assigned!")
		return
	_camera.global_position = target.global_position + offset
