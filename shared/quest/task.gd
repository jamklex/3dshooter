extends Node

class_name Task

var _name: String
var status: Status = Status.UNKNOWN
var desc: String
var short: String
var dialog: TaskDialog
var success_result: TaskResult
var fail_result: TaskResult

@onready var short_ui = $short as Control

static func from(dict: Dictionary, name: String = "") -> Task:
	var task = Task.new()
	task._name = dict.get("name", name)
	task.desc = dict.get("desc")
	task.short = dict.get("short")
	if dict.has("dialog"):
		task.dialog = TaskDialog.from(dict.get("dialog"), task._name)
	if dict.has("success"):
		task.success_result = TaskResult.from(dict.get("success"))
	if dict.has("failure"):
		task.fail_result = TaskResult.from(dict.get("failure"))
	print("Task " + task.short + " loaded")
	return task

static func create(name: String, status: Status, desc: String, short: String, dialog: Dictionary, success_result: TaskResult, fail_result: TaskResult) -> Task:
	var task = Task.new()
	task._name = name
	task.status = status
	task.desc = desc
	task.short = short
	task.dialog = dialog
	task.success_result = success_result
	task.fail_result = fail_result
	return task

enum Status {
	UNKNOWN, ACTIVE, SUCCEEDED, FAILED
}

func load_visuals():
	for s in Status.values():
		var node = short_ui.get_node(s.to_lower()) as Label
		node.visible = s == status
		node.text = short
