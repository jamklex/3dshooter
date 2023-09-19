extends Object

class_name Task

var name: String
var desc: String
var short: String
var dialog: TaskDialog
var success_result: TaskResult
var fail_result: TaskResult

static func from(json: JSON) -> Task:
	var task = Task.new()
	return task

static func create(name: String, desc: String, short: String, dialog: Dictionary, success_result: TaskResult, fail_result: TaskResult) -> Task:
	var task = Task.new()
	task.name = name
	task.desc = desc
	task.short = short
	task.dialog = dialog
	task.success_result = success_result
	task.fail_result = fail_result
	return task
