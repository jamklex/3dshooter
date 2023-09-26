class_name Task
extends Node

var title: String
var status: Status = Status.UNKNOWN
var desc: String
var short: String
var dialog: TaskDialog
var success_result: TaskResult
var fail_result: TaskResult
var hide_if_unknown: bool

@onready var short_ui = $short as Control
const scene = preload("res://shared/quest/scenes/task.tscn")

static func from(dict: Dictionary, name: String = "") -> Task:
	var task = scene.instantiate()
	task.title = dict.get("name", name)
	task.desc = dict.get("desc")
	task.short = dict.get("short")
	task.hide_if_unknown = dict.get("hide", false)
	if dict.has("dialog"):
		task.dialog = TaskDialog.from(dict.get("dialog"), task.title)
	if dict.has("success"):
		task.success_result = TaskResult.from(dict.get("success"))
	if dict.has("failure"):
		task.fail_result = TaskResult.from(dict.get("failure"))
	print("Task " + task.short + " loaded")
	return task

enum Status {
	UNKNOWN, ACTIVE, SUCCEEDED, FAILED
}

func set_active():
	status = Status.ACTIVE

func refresh_data():
	for s in Status.values():
		var node = short_ui.get_node(Status.keys()[s].to_lower()) as Label
		node.visible = s == status
		node.text = short
