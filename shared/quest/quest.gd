extends Node

class_name Quest

var _name: String = ""
var tasks: Array = []

static func from(tasks: Array) -> Quest:
	var quest = Quest.new()
	for t in tasks:
		var task = Task.from(t, quest._name)
		quest.add_task(task)
		if !quest._name:
			quest._name = task._name
	print("Quest " + quest._name + " loaded")
	return quest

func add_task(task: Task):
	tasks.push_back(task)

func set_succeed(task: Task):
	task.status = Task.Status.SUCCEEDED

func set_failed(task: Task):
	task.status = Task.Status.FAILED

func set_active(task: Task):
	task.status = Task.Status.ACTIVE

func get_active_task() -> Task:
	for task in tasks:
		if task.status == Task.Status.ACTIVE:
			return task
	return null
