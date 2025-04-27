@tool
extends Node3D
class_name FloatingLabel

@export var text: String:
	set(new_text):
		text = new_text
		$SubViewport/MarginContainer/PanelContainer/MarginContainer/Label.text = text
@onready var _meshInstance: MeshInstance3D = $MeshInstance3D

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not WorldUtil.player_cam:
		return
	var current_cam_pos = WorldUtil.player_cam.global_position
	_meshInstance.look_at(current_cam_pos, Vector3.UP, true)
