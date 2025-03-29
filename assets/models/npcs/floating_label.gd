@tool
extends Node3D
class_name FloatingLabel

@export var text: String:
	set(new_text):
		text = new_text
		$SubViewport/PanelContainer/MarginContainer/Label.text = text
var last_cam_pos: Vector3
var current_cam_pos: Vector3

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not WorldUtil.player_cam:
		return
	current_cam_pos = WorldUtil.player_cam.global_position
	if current_cam_pos == last_cam_pos:
		return
	last_cam_pos = current_cam_pos
	look_at(current_cam_pos)
	rotation.x = 0
	rotation.z = 0
